param(
    [string]$OutFile = "$PSScriptRoot\a15-live-media.json",
    [switch]$Loop
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$code = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Collections.Generic;

[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
    int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IntPtr ppDevices);
    int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppEndpoint);
}

[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
    int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface);
}

[Guid("C02216F6-8C67-4B5B-9D00-D008E73E0064"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioMeterInformation {
    int GetPeakValue(out float pfPeak);
}

[Guid("77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionManager2 {
    int GetAudioSessionControl(IntPtr AudioSessionGuid, uint StreamFlags, out IntPtr SessionControl);
    int GetSimpleAudioVolume(IntPtr AudioSessionGuid, uint StreamFlags, out IntPtr AudioVolume);
    int GetSessionEnumerator(out IAudioSessionEnumerator SessionEnum);
}

[Guid("E2F5BB11-0570-40CA-ACDD-3AA01277DEE8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionEnumerator {
    int GetCount(out int SessionCount);
    int GetSession(int SessionCount, out IAudioSessionControl Session);
}

[Guid("F4B1A599-7266-4319-A8CA-E70ACB11E8CD"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionControl {
    int GetState(out int pRetVal);
    int GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
}

[Guid("bfb7ff88-7239-4fc9-8fa2-07c950be9c6d"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioSessionControl2 {
    int GetState(out int pRetVal);
    int GetDisplayName([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetDisplayName([MarshalAs(UnmanagedType.LPWStr)] string Value, Guid EventContext);
    int GetIconPath([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int SetIconPath([MarshalAs(UnmanagedType.LPWStr)] string Value, Guid EventContext);
    int GetGroupingParam(out Guid pRetVal);
    int SetGroupingParam(Guid Override, Guid EventContext);
    int RegisterAudioSessionNotification(IntPtr NewNotifications);
    int UnregisterAudioSessionNotification(IntPtr NewNotifications);
    int GetSessionIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int GetSessionInstanceIdentifier([MarshalAs(UnmanagedType.LPWStr)] out string pRetVal);
    int GetProcessId(out uint pRetVal);
}

public class AudioSessionItem {
    public uint Pid;
    public string ProcessName;
    public int State; // 0=Inactive(Paused), 1=Active(Playing), 2=Expired
    public string DisplayName;
    public float Peak;
    public string WindowTitle;
}

public class AudioProbe {
    private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc enumProc, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")]
    private static extern int GetWindowTextLength(IntPtr hWnd);
    [DllImport("user32.dll")]
    private static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    public static Dictionary<uint, string> GetWindowTitles() {
        Dictionary<uint, string> titles = new Dictionary<uint, string>();
        EnumWindows(delegate(IntPtr hWnd, IntPtr lParam) {
            int length = GetWindowTextLength(hWnd);
            if (length == 0) return true;
            StringBuilder sb = new StringBuilder(length + 1);
            GetWindowText(hWnd, sb, sb.Capacity);
            string title = sb.ToString().Trim();
            if (title.Length > 0 && title != "Default IME" && title != "MSCTFIME UI") {
                uint pid;
                GetWindowThreadProcessId(hWnd, out pid);
                bool isMediaTitle = title.Contains(".mp3") || title.Contains(".flac") || title.Contains(".mp4") || title.Contains(".mkv") || title.Contains(".wav") || title.Contains("YouTube") || title.Contains("Spotify") || title.Contains("Music");
                if (isMediaTitle || (IsWindowVisible(hWnd) && !titles.ContainsKey(pid))) {
                    titles[pid] = title;
                }
            }
            return true;
        }, IntPtr.Zero);
        return titles;
    }

    public static List<AudioSessionItem> GetSessions(out float masterPeak) {
        masterPeak = 0f;
        List<AudioSessionItem> list = new List<AudioSessionItem>();
        try {
            Dictionary<uint, string> winTitles = GetWindowTitles();
            Type t = Type.GetTypeFromCLSID(new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E"));
            IMMDeviceEnumerator enumerator = (IMMDeviceEnumerator)Activator.CreateInstance(t);
            IMMDevice dev;
            enumerator.GetDefaultAudioEndpoint(0, 1, out dev);
            Guid meterGuid = typeof(IAudioMeterInformation).GUID;
            object oMeter;
            dev.Activate(ref meterGuid, 23, IntPtr.Zero, out oMeter);
            ((IAudioMeterInformation)oMeter).GetPeakValue(out masterPeak);

            Guid mgrGuid = typeof(IAudioSessionManager2).GUID;
            object oMgr;
            dev.Activate(ref mgrGuid, 23, IntPtr.Zero, out oMgr);
            IAudioSessionEnumerator sessionEnum;
            ((IAudioSessionManager2)oMgr).GetSessionEnumerator(out sessionEnum);
            int count = 0;
            sessionEnum.GetCount(out count);
            for (int i = 0; i < count; i++) {
                IAudioSessionControl ctrl;
                sessionEnum.GetSession(i, out ctrl);
                IAudioSessionControl2 ctrl2 = (IAudioSessionControl2)ctrl;
                int state;
                ctrl2.GetState(out state);
                string disp;
                ctrl2.GetDisplayName(out disp);
                uint pid;
                ctrl2.GetProcessId(out pid);

                float sPeak = 0f;
                try {
                    IAudioMeterInformation sMeter = (IAudioMeterInformation)ctrl;
                    sMeter.GetPeakValue(out sPeak);
                } catch {}

                string pname = "System";
                try {
                    if (pid > 0) pname = Process.GetProcessById((int)pid).ProcessName;
                } catch {}

                string wTitle = "";
                if (winTitles.ContainsKey(pid)) {
                    wTitle = winTitles[pid];
                }

                if (pid > 0 && !pname.Equals("Idle", StringComparison.OrdinalIgnoreCase) && !pname.Equals("TextInputHost", StringComparison.OrdinalIgnoreCase)) {
                    AudioSessionItem item = new AudioSessionItem();
                    item.Pid = pid;
                    item.ProcessName = pname;
                    item.State = state;
                    item.DisplayName = disp ?? "";
                    item.Peak = sPeak;
                    item.WindowTitle = wTitle ?? "";
                    list.Add(item);
                }
            }
        } catch {}
        return list;
    }
}
'@

Add-Type -TypeDefinition $code -ErrorAction SilentlyContinue

function Get-FriendlyAppName([string]$procName) {
    $pn = $procName.ToLower()
    if ($pn -match "chrome") { return "Google Chrome (Web Browser)" }
    if ($pn -match "msedge") { return "Microsoft Edge (Web Browser)" }
    if ($pn -match "firefox") { return "Mozilla Firefox (Web Browser)" }
    if ($pn -match "brave") { return "Brave Browser" }
    if ($pn -match "opera") { return "Opera Browser" }
    if ($pn -match "mpc-hc") { return "MPC-HC (Media Player Classic)" }
    if ($pn -match "spotify") { return "Spotify Music" }
    if ($pn -match "vlc") { return "VLC Media Player" }
    if ($pn -match "potplayer") { return "PotPlayer" }
    if ($pn -match "wmplayer" -or $pn -match "media.player") { return "Windows Media Player" }
    return $procName
}

$cmdCache = @{}

function Get-MediaTrackFromPid([uint32]$targetPid, [string]$dispName, [string]$winTitle, [string]$procName) {
    if ($dispName -ne "" -and $dispName -notmatch "@%SystemRoot%" -and $dispName -ne $procName) {
        return $dispName
    }
    if ($winTitle -ne "" -and $winTitle -ne $procName) {
        return $winTitle
    }
    if ($cmdCache.ContainsKey($targetPid)) {
        return $cmdCache[$targetPid]
    }
    try {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId = $targetPid" -ErrorAction SilentlyContinue).CommandLine
        if ($cmd) {
            $matches = [regex]::Matches($cmd, '"([^"]+\.(mp3|flac|wav|m4a|ogg|aac|mp4|mkv|avi|webm))"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($matches.Count -gt 0) {
                $fullPath = $matches[0].Groups[1].Value
                $fileName = [System.IO.Path]::GetFileName($fullPath)
                $res = "$fileName [$fullPath]"
                $cmdCache[$targetPid] = $res
                return $res
            }
        }
    } catch {}
    return "$procName Audio Stream (PID $targetPid)"
}

function Update-Snapshot() {
    $masterPeak = 0.0
    $sessions = [AudioProbe]::GetSessions([ref]$masterPeak)

    # Sort sessions so active/highest peak comes first
    $sortedSessions = $sessions | Sort-Object -Property @{Expression={$_.State -eq 1}; Ascending=$false}, @{Expression={$_.Peak}; Ascending=$false}
    $activeSession = if ($sortedSessions.Count -gt 0) { $sortedSessions[0] } else { $null }

    $sourceApp = "-"
    $trackTitle = "-"
    $playbackState = "Paused"

    if ($activeSession) {
        $sourceApp = Get-FriendlyAppName $activeSession.ProcessName
        $trackTitle = Get-MediaTrackFromPid $activeSession.Pid $activeSession.DisplayName $activeSession.WindowTitle $activeSession.ProcessName

        if ($activeSession.State -eq 1 -or $activeSession.Peak -gt 0.0005 -or $masterPeak -gt 0.0005) {
            $playbackState = "Playing"
        } else {
            $playbackState = "Paused"
        }
    }

    $sessionList = @()
    foreach ($s in $sortedSessions) {
        $fApp = Get-FriendlyAppName $s.ProcessName
        $tTitle = Get-MediaTrackFromPid $s.Pid $s.DisplayName $s.WindowTitle $s.ProcessName
        $sessionList += @{
            pid = $s.Pid
            app = $fApp
            rawProc = $s.ProcessName
            state = if ($s.State -eq 1 -or $s.Peak -gt 0.0005) { "Playing" } else { "Paused" }
            title = $tTitle
            peak = [Math]::Round($s.Peak * 100, 1)
        }
    }

    $out = @{
        audioEndpoint = "Headphones (A15 - 41:42:F9:E8:1A:CE)"
        endpointConnected = $true
        playbackStatus = $playbackState
        sourceApp = $sourceApp
        title = $trackTitle
        volumePeakPercent = [Math]::Round($masterPeak * 100, 1)
        updatedAt = (Get-Date).ToString("HH:mm:ss")
        sessions = $sessionList
    }

    $json = $out | ConvertTo-Json -Compress -Depth 4
    [System.IO.File]::WriteAllText($OutFile, $json, [System.Text.Encoding]::UTF8)
    if (-not $Loop) {
        Write-Output $json
    }
}

if ($Loop) {
    while ($true) {
        Update-Snapshot
        Start-Sleep -Milliseconds 1200
    }
} else {
    Update-Snapshot
}
