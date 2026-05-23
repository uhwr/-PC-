# BrightBeacon 操作文档

## 1. 文件位置

脚本文件：

```text
C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1
```

该脚本用于在授权测试环境中，通过 Windows BLE 广播 API 模拟一个 iBeacon 信号。

## 2. 当前 Beacon 参数

脚本当前配置如下：

```text
UUID:  FDA50693-A4E2-4FB1-AFCF-C6EB07647825
Major: 10199
Minor: 42474
TxPower: BF（-65 dBm）
```

对应 iBeacon manufacturer payload：

```text
02 15 FD A5 06 93 A4 E2 4F B1 AF CF C6 EB 07 64 78 25 27 D7 A5 EA BF
```

## 3. 运行方法

1. 确认电脑蓝牙已开启。
2. 右键开始菜单，打开"终端（管理员）"或"Windows PowerShell（管理员）"。
3. 执行：

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1"
```

4. 看到类似以下输出表示脚本已尝试启动广播：

```text
Starting BrightBeacon iBeacon advertisement...
UUID:  FDA50693-A4E2-4FB1-AFCF-C6EB07647825
Major: 10199
Minor: 42474
Status: Started
Press Enter to stop advertising.
```

5. 测试完成后，在该窗口按 Enter 停止广播。

## 4. 修改 UUID / Major / Minor

用记事本打开：

```text
C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1
```

修改文件开头这几行：

```powershell
$uuid = [Guid]"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"
$major = 10199
$minor = 42474
$txPower = 0xBF
```

保存后重新运行脚本即可。

注意：

- UUID 必须是标准格式：`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Major 范围：`0` 到 `65535`
- Minor 范围：`0` 到 `65535`
- `$txPower = 0xBF` 对应软件里的 measured power，通常不需要改。

## 5. 如何确认是否发出信号

可以使用以下方式扫描验证：

- 手机上的 BLE Scanner / nRF Connect 等工具
- 另一台支持 BLE 扫描的电脑
- 目标测试设备或授权测试 App

扫描时应看到 Apple manufacturer data，Company ID 为：

```text
0x004C
```

并包含以下 iBeacon 内容：

```text
02 15 FD A5 06 93 A4 E2 4F B1 AF CF C6 EB 07 64 78 25 27 D7 A5 EA BF
```

## 6. 常见问题

### 6.1 Status 不是 Started

可能原因：

- 蓝牙未开启
- 蓝牙驱动不支持 BLE 广播
- 当前蓝牙设备被系统或其他程序占用
- Windows 权限或驱动限制

处理方式：

1. 关闭再打开蓝牙。
2. 断开蓝牙耳机、手柄等外设后重试。
3. 重启电脑后重试。
4. 使用支持 BLE 广播的 USB 蓝牙适配器。

### 6.2 手机扫不到 Beacon

可能原因：

- Windows 蓝牙硬件支持连接设备，但不支持作为 BLE Peripheral 广播。
- 手机扫描工具过滤了 iBeacon 数据。
- 广播功率较低，距离太远。
- 目标设备只接受特定格式或特定发射参数。

建议：

1. 手机靠近电脑测试。
2. 用 nRF Connect 查看原始 manufacturer data。
3. 如果 Windows 一直扫不到，换 Linux + USB 蓝牙适配器、ESP32 或 nRF52840 会更稳定。

### 6.3 提示脚本无法运行

如果提示执行策略限制，可以使用本文档中的命令：

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1"
```

不要直接双击运行，因为双击可能会立即关闭窗口，看不到报错信息。

## 7. 技术说明

从 `BrightBeacon.apk` 的"模拟 Beacon"页面分析到，它构造的是标准 iBeacon 广播：

```text
Manufacturer ID: 0x004C
Beacon Type:     02 15
UUID:            FDA50693-A4E2-4FB1-AFCF-C6EB07647825
Major:           10199 / 0x27D7
Minor:           42474 / 0xA5EA
Measured Power:  BF
```

Windows 脚本使用 `BluetoothLEAdvertisementPublisher` 广播相同 manufacturer data。

## 8. 使用范围

仅用于已授权的测试环境。不要用于绕过考勤、签到、门禁、定位、访问控制或其他未授权场景。
