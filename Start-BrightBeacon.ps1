Add-Type -AssemblyName System.Runtime.WindowsRuntime

$uuid = [Guid]"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
$major = 10199
$minor = 42474
$txPower = 0xBF

$uuidBytes = $uuid.ToByteArray()

$ibeaconUuid = [byte[]]@(
    $uuidBytes[3], $uuidBytes[2], $uuidBytes[1], $uuidBytes[0],
    $uuidBytes[5], $uuidBytes[4],
    $uuidBytes[7], $uuidBytes[6],
    $uuidBytes[8], $uuidBytes[9], $uuidBytes[10], $uuidBytes[11],
    $uuidBytes[12], $uuidBytes[13], $uuidBytes[14], $uuidBytes[15]
)

$payload = New-Object byte[] 23
$payload[0] = 0x02
$payload[1] = 0x15
[Array]::Copy($ibeaconUuid, 0, $payload, 2, 16)
$payload[18] = [byte](($major -shr 8) -band 0xFF)
$payload[19] = [byte]($major -band 0xFF)
$payload[20] = [byte](($minor -shr 8) -band 0xFF)
$payload[21] = [byte]($minor -band 0xFF)
$payload[22] = [byte]$txPower

$publisherType = [Windows.Devices.Bluetooth.Advertisement.BluetoothLEAdvertisementPublisher,Windows.Devices.Bluetooth,ContentType=WindowsRuntime]
$manufacturerDataType = [Windows.Devices.Bluetooth.Advertisement.BluetoothLEManufacturerData,Windows.Devices.Bluetooth,ContentType=WindowsRuntime]

$publisher = $publisherType::new()

$manufacturerData = $manufacturerDataType::new()
$manufacturerData.CompanyId = 0x004C
$manufacturerData.Data = [System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions]::AsBuffer($payload)
$manufacturerDataCollectionType = [System.Collections.Generic.ICollection``1].MakeGenericType($manufacturerDataType)
$manufacturerDataCollectionType.GetMethod("Add").Invoke($publisher.Advertisement.ManufacturerData, [object[]]@($manufacturerData)) | Out-Null

$payloadHex = ($payload | ForEach-Object { $_.ToString("X2") }) -join " "
Write-Host "Starting BrightBeacon iBeacon advertisement..."
Write-Host "UUID:  $uuid"
Write-Host "Major: $major"
Write-Host "Minor: $minor"
Write-Host "Manufacturer payload: $payloadHex"

try {
    $publisher.Start()
    $deadline = (Get-Date).AddSeconds(10)
    while ((Get-Date) -lt $deadline -and $publisher.Status -eq "Waiting") {
        Start-Sleep -Milliseconds 250
    }
    Write-Host "Status: $($publisher.Status)"
    Write-Host "Press Enter to stop advertising."
    [Console]::ReadLine() | Out-Null
}
finally {
    if ($publisher.Status -ne "Stopped") {
        $publisher.Stop()
    }
    Write-Host "Stopped."
}
