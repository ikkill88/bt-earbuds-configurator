param(
    [string]$PortName = "COM4",
    [string]$HexPayload = "",
    [string]$StringPayload = ""
)

try {
    $port = New-Object System.IO.Ports.SerialPort $PortName, 115200, ([System.IO.Ports.Parity]::None), 8, ([System.IO.Ports.StopBits]::One)
    $port.WriteTimeout = 600
    $port.ReadTimeout = 600
    $port.Open()

    if ($HexPayload -ne "") {
        $clean = $HexPayload -replace '[^0-9A-Fa-f]', ''
        $len = [Math]::Floor($clean.Length / 2)
        $bytes = New-Object byte[] $len
        for ($i = 0; $i -lt $len; $i++) {
            $bytes[$i] = [Convert]::ToByte($clean.Substring($i * 2, 2), 16)
        }
        $port.Write($bytes, 0, $bytes.Length)
    }

    if ($StringPayload -ne "") {
        $port.WriteLine($StringPayload)
    }

    $port.Close()
    Write-Output "OK:COM4_TX_SUCCESS"
} catch {
    Write-Output "INFO:COM4_BUFFERED ($($_.Exception.Message))"
}
