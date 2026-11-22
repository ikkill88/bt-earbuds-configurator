param(
    [string]$StateFile = "$PSScriptRoot\a15-lock-state.json",
    [string]$LogFile = "$PSScriptRoot\a15-hook-events.log"
)

$source = @"
using System;
using System.IO;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class A15MediaShieldHook {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int WM_SYSKEYDOWN = 0x0104;

    // Virtual Key Codes for AVRCP Bluetooth Touch Sensor Media Commands
    private const int VK_MEDIA_NEXT_TRACK = 0xB0;
    private const int VK_MEDIA_PREV_TRACK = 0xB1;
    private const int VK_MEDIA_STOP       = 0xB2;
    private const int VK_MEDIA_PLAY_PAUSE = 0xB3;

    private static LowLevelKeyboardProc _proc = HookCallback;
    private static IntPtr _hookID = IntPtr.Zero;
    public static string StateFilePath = "";
    public static string LogFilePath = "";

    public static void Start(string stateFile, string logFile) {
        StateFilePath = stateFile;
        LogFilePath = logFile;
        _hookID = SetHook(_proc);
        Application.Run();
        UnhookWindowsHookEx(_hookID);
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc) {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule curModule = curProcess.MainModule) {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static bool ShouldBlockKey(int vkCode, out string keyName) {
        keyName = "";
        if (vkCode == VK_MEDIA_PLAY_PAUSE) keyName = "PLAY_PAUSE (Single Tap)";
        else if (vkCode == VK_MEDIA_NEXT_TRACK) keyName = "NEXT_TRACK (Double Tap)";
        else if (vkCode == VK_MEDIA_PREV_TRACK) keyName = "PREV_TRACK (Triple Tap)";
        else if (vkCode == VK_MEDIA_STOP) keyName = "MEDIA_STOP (Long Press)";
        else return false;

        try {
            if (!File.Exists(StateFilePath)) return false;
            string json = File.ReadAllText(StateFilePath);
            if (json.Contains("\"masterLocked\":true")) return true;
            if (vkCode == VK_MEDIA_PLAY_PAUSE && json.Contains("\"singleTap\":true")) return true;
            if (vkCode == VK_MEDIA_NEXT_TRACK && json.Contains("\"doubleTap\":true")) return true;
            if (vkCode == VK_MEDIA_PREV_TRACK && json.Contains("\"tripleTap\":true")) return true;
            if (vkCode == VK_MEDIA_STOP && json.Contains("\"longPress\":true")) return true;
        } catch {
            return false;
        }
        return false;
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && (wParam == (IntPtr)WM_KEYDOWN || wParam == (IntPtr)WM_SYSKEYDOWN)) {
            int vkCode = Marshal.ReadInt32(lParam);
            string keyName;
            if (ShouldBlockKey(vkCode, out keyName)) {
                try {
                    string line = DateTime.Now.ToString("HH:mm:ss") + "|BLOCKED_A15_AVRCP|" + keyName + "|VK=0x" + vkCode.ToString("X2") + Environment.NewLine;
                    File.AppendAllText(LogFilePath, line);
                } catch {}
                // Return non-zero (1) to swallow and block the ghost-touch media key across all Windows apps!
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);
}
"@

Add-Type -TypeDefinition $source -ReferencedAssemblies System.Windows.Forms
[A15MediaShieldHook]::Start($StateFile, $LogFile)
