# 我去图书馆 PC 端模拟蓝牙签到

> Windows PC BrightBeacon iBeacon broadcast simulation for Woqu Library BLE sign-in testing.

## 项目简介

本仓库用于在 Windows PC 上通过 PowerShell 模拟 BrightBeacon iBeacon 广播，以便在授权测试环境中对“我去图书馆”相关蓝牙签到链路进行验证、观察与复现。

This repository provides a small Windows PowerShell setup for simulating BrightBeacon iBeacon broadcasts in authorized BLE sign-in testing scenarios.

仓库目标是保留一个轻量、直接、可读的桌面端蓝牙广播模拟方案，而不是混合小程序解包、管理端分析或其他不相关内容。

## 仓库定位

这个仓库主要用于：

- 在 Windows 环境中启动一份固定参数的 iBeacon 广播
- 复现 PC 端蓝牙签到模拟流程
- 记录脚本的运行方式、参数说明和修改过程
- 为后续继续调整广播参数提供基础版本

It is intentionally kept small and focused on the BLE broadcast script plus supporting notes.

## 当前目录结构

```text
.
├─ README.md
├─ .gitignore
├─ Start-BrightBeacon.ps1
└─ 相关文档/
```

各文件与目录说明如下：

- `Start-BrightBeacon.ps1`
  主脚本。负责构造 iBeacon 广播负载、初始化 Windows 蓝牙广播对象并启动广播。

- `相关文档/BrightBeacon_操作文档.md`
  操作说明文档，适合查看运行方法、参数调整方式和常见注意事项。

- `相关文档/Start-BrightBeacon-修改过程总结.md`
  记录脚本整理和修改过程，便于回看当前版本是怎样形成的。

## English Summary

- `Start-BrightBeacon.ps1`
  Main script that builds the iBeacon payload and starts Bluetooth LE advertising on Windows.

- `相关文档/BrightBeacon_操作文档.md`
  Usage notes, parameter adjustment guide, and common troubleshooting details.

- `相关文档/Start-BrightBeacon-修改过程总结.md`
  Change log and cleanup notes for the current script version.

## 脚本行为说明

当前脚本会：

- 加载 Windows Runtime 相关程序集
- 构造一组固定的 iBeacon UUID、Major、Minor 和 Tx Power
- 生成 Manufacturer Data 负载
- 通过 Windows 蓝牙广播接口启动广播
- 在终端输出当前广播参数
- 等待用户按回车后停止广播

从当前脚本内容来看，默认参数为固定值，适合做基础测试和行为复现。如果后续需要多场景切换，可以再继续扩展为参数化脚本。

## 广播参数表

当前脚本内置的主要广播参数如下：

| 参数 | 当前值 | 说明 |
| --- | --- | --- |
| `UUID` | `FDA50693-A4E2-4FB1-AFCF-C6EB07647825` | iBeacon 广播使用的 UUID |
| `Major` | `10199` | 主编号，用于区分一组 beacon |
| `Minor` | `42474` | 次编号，用于区分具体 beacon |
| `Tx Power` | `0xBF` | 发射功率校准值，写入广播负载 |
| `CompanyId` | `0x004C` | Apple 的 Manufacturer ID，用于 iBeacon 数据格式 |
| `Payload Length` | `23` 字节 | 当前脚本构造的 Manufacturer Data 长度 |

如果要调整广播行为，最直接的入口就是修改 `Start-BrightBeacon.ps1` 顶部定义的这些参数。

## 运行方式

在 PowerShell 中执行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\Start-BrightBeacon.ps1"
```

运行后终端会显示：

- UUID
- Major
- Minor
- Manufacturer payload
- 广播状态

按回车后脚本会主动停止广播。

Run the script from PowerShell and press Enter to stop broadcasting.

## 适用环境

建议在以下环境中使用：

- Windows 设备
- 支持蓝牙广播相关能力的系统环境
- 已授权的测试、验证或研究场景

Recommended environment in English:

- Windows desktop or laptop
- Bluetooth LE capable environment
- Authorized testing or research scenario

如果设备本身蓝牙能力、系统权限或运行环境不足，脚本可能无法正常启动广播。

## 建议阅读顺序

第一次查看这个仓库时，建议按下面顺序阅读：

1. 先看本 README，了解仓库用途和结构。
2. 再看 `相关文档/BrightBeacon_操作文档.md`，掌握运行方法和调参位置。
3. 最后查看 `Start-BrightBeacon.ps1`，确认广播负载和执行流程。

## 后续可扩展方向

如果后面还要继续维护这个仓库，可以考虑补充：

- 将 UUID、Major、Minor、Tx Power 改为命令行参数
- 增加运行前环境检查
- 增加异常处理和更清晰的状态输出
- 补充不同测试场景下的参数样例
- 增加更详细的广播数据结构说明

## 本次整理内容

本次已完成以下整理：

- 将仓库标题与说明统一为“我去图书馆 PC 端模拟蓝牙签到”
- README 改为围绕脚本用途、结构和运行方式展开
- 仓库内容收敛为蓝牙模拟签到所需最小集合
- 去除与小程序解包分析无关的混杂定位

## 使用边界

本仓库只保留 PC 端蓝牙模拟签到所需内容，不用于存放：

- 小程序解包结果
- 管理端前端代码
- 无关分析文档
- 临时测试文件或本地备份目录

## 免责声明

仅用于已获授权的测试、研究与验证场景。请勿用于绕过签到、考勤、门禁、定位或任何未经授权的用途。

For authorized testing and research only. Do not use this script for bypassing sign-in, attendance, access control, location checks, or any unauthorized activity.
