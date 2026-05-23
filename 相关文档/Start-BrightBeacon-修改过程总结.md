# Start-BrightBeacon 脚本修改过程总结

日期：2026-05-07

## 目标

将桌面脚本：

```text
C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1
```

修复到可以正常启动 BrightBeacon/iBeacon 广播，并将 `.ps1` 文件的默认打开方式从记事本改为直接使用 Windows PowerShell 运行。

## 一、脚本运行问题排查与修复

### 1. 初始运行失败

首次测试脚本时，在设置 manufacturer data 时失败：

```text
Cannot convert the "System.__ComObject" value of type "System.__ComObject" to type "Windows.Storage.Streams.IBuffer".
```

出错位置：

```powershell
$manufacturerData.Data = $writer.DetachBuffer()
```

原因：Windows PowerShell 5.1 对部分 WinRT 对象的类型转换支持不完整，`DataWriter.DetachBuffer()` 返回的对象被包装为 `System.__ComObject`，不能直接赋值给 `Windows.Storage.Streams.IBuffer`。

### 2. 修复 IBuffer 转换问题

加入 WinRT 辅助程序集：

```powershell
Add-Type -AssemblyName System.Runtime.WindowsRuntime
```

并将原来的：

```powershell
$manufacturerData.Data = $writer.DetachBuffer()
```

改为：

```powershell
$manufacturerData.Data = [System.Runtime.InteropServices.WindowsRuntime.WindowsRuntimeBufferExtensions]::AsBuffer($payload)
```

这样可以直接把 PowerShell 的 `byte[]` 转成 WinRT `IBuffer`。

### 3. 修复 ManufacturerData.Add 问题

修复 IBuffer 后继续运行，又遇到：

```text
Method invocation failed because [System.__ComObject] does not contain a method named 'Add'.
```

出错位置：

```powershell
$publisher.Advertisement.ManufacturerData.Add($manufacturerData)
```

原因：Windows PowerShell 5.1 中 `ManufacturerData` 这个 WinRT 集合被暴露为 `System.__ComObject`，不能直接调用 `.Add()`。

最终改用泛型 `ICollection<T>` 的反射调用：

```powershell
$manufacturerDataCollectionType = [System.Collections.Generic.ICollection``1].MakeGenericType($manufacturerDataType)
$manufacturerDataCollectionType.GetMethod("Add").Invoke($publisher.Advertisement.ManufacturerData, [object[]]@($manufacturerData)) | Out-Null
```

### 4. 修复 Start() 参数异常

修复集合添加后，脚本继续运行到 `$publisher.Start()`，但出现：

```text
Exception calling "Start" with "0" argument(s): "Value does not fall within the expected range."
```

排查后发现问题来自手动设置 BLE advertisement flags：

```powershell
$publisher.Advertisement.Flags = $flagsType::GeneralDiscoverableMode -bor $flagsType::ClassicNotSupported
```

测试结果显示：

- 不设置 Flags：可以启动
- 设置 Flags：`Start()` 抛出参数异常

因此移除了手动设置 Flags 的代码，让 Windows 自动处理。

### 5. 增加状态等待逻辑

移除 Flags 后，脚本启动时状态一开始可能是：

```text
Status: Waiting
```

继续等待后会变成：

```text
Status: Started
```

因此加入最多 10 秒等待逻辑：

```powershell
$publisher.Start()
$deadline = (Get-Date).AddSeconds(10)
while ((Get-Date) -lt $deadline -and $publisher.Status -eq "Waiting") {
    Start-Sleep -Milliseconds 250
}
Write-Host "Status: $($publisher.Status)"
```

## 二、最终脚本测试结果

最终运行：

```powershell
& "C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1"
```

输出结果：

```text
Starting BrightBeacon iBeacon advertisement...
UUID:  fda50693-a4e2-4fb1-afcf-c6eb07647825
Major: 10199
Minor: 42474
Manufacturer payload: 02 15 FD A5 06 93 A4 E2 4F B1 AF CF C6 EB 07 64 78 25 27 D7 A5 EA BF
Status: Started
Press Enter to stop advertising.
```

结论：脚本已经可以成功启动 iBeacon 广播。

## 三、蓝牙适配器状态确认

检查到本机蓝牙服务正在运行：

```text
Name: bthserv
Status: Running
```

检查到默认蓝牙适配器支持 BLE 广播相关能力：

```text
IsPeripheralRoleSupported: True
IsCentralRoleSupported: True
IsLowEnergySupported: True
```

因此硬件和系统能力满足 BLE 广播要求。

## 四、修改 .ps1 默认打开方式

### 1. 初始状态

`.ps1` 文件默认打开方式被 Windows 的 `UserChoice` 锁定为记事本：

```text
ProgId: AppXxf01pj590w7z9mxmyv3nx0a9ewj3e51g
```

实际 Shell 查询结果指向：

```text
C:\Program Files\WindowsApps\Microsoft.WindowsNotepad_...\Notepad\Notepad.exe
```

### 2. 备份注册表

修改前已备份相关注册表项到桌面：

```text
C:\Users\Administrator\Desktop\ps1-association-backup-20260507-124011
```

### 3. 设置 PowerShell 运行命令

将 `.ps1` 文件类型关联到：

```text
Microsoft.PowerShellScript.1
```

并设置运行命令为：

```text
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "%1" %*
```

涉及的主要注册表位置：

```text
HKEY_CURRENT_USER\Software\Classes\.ps1
HKEY_CURRENT_USER\Software\Classes\.ps1\Shell\Open\Command
HKEY_CURRENT_USER\Software\Classes\Microsoft.PowerShellScript.1\Shell\Open\Command
HKEY_LOCAL_MACHINE\Software\Classes\.ps1
HKEY_LOCAL_MACHINE\Software\Classes\Microsoft.PowerShellScript.1\Shell\Open\Command
```

### 4. 解除 UserChoice 锁定

Windows 的 `UserChoice` 项存在拒绝写入权限：

```text
MECH\Administrator Deny SetValue
```

经确认后，只针对 `.ps1\UserChoice` 这一项移除了拒绝写入规则，并删除该 UserChoice 项，使系统不再强制使用记事本。

### 5. 修正 ftype 命令

过程中曾通过 `assoc/ftype` 设置机器级关联，但第一次 `ftype` 命令的引号被 PowerShell 转义错误。随后直接通过注册表修正为正确命令：

```text
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "%1" %*
```

## 五、.ps1 打开方式验证

创建临时测试脚本：

```text
C:\Users\Administrator\Desktop\ps1-association-test.ps1
```

通过系统 Shell 打开该 `.ps1` 文件后，测试脚本成功执行，并写入测试标记文件。

验证输出：

```text
Shell association executed PS1 successfully
ran
```

结论：现在双击或通过系统 Shell 打开 `.ps1` 文件会执行脚本，而不是用记事本打开。

## 六、当前最终状态

### BrightBeacon 脚本

```text
C:\Users\Administrator\Desktop\Start-BrightBeacon.ps1
```

状态：可正常运行。

成功状态应显示：

```text
Status: Started
```

### .ps1 默认打开方式

状态：已改为 Windows PowerShell 运行。

运行命令：

```text
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "%1" %*
```

## 七、注意事项

1. 现在双击任何 `.ps1` 文件都会执行它。
2. 不要双击来源不明或不可信的 PowerShell 脚本。
3. 如果要停止 BrightBeacon 广播，在脚本窗口中按 Enter 即可。
4. 如果以后想恢复默认记事本打开方式，可以使用桌面上的注册表备份目录进行参考或恢复。

备份目录：

```text
C:\Users\Administrator\Desktop\ps1-association-backup-20260507-124011
```
