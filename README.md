# 我去图书馆 PC 端模拟蓝牙签到

## 项目简介

在 Windows PC 上通过 PowerShell 脚本模拟 BrightBeacon iBeacon 广播信号，
实现桌面端蓝牙签到模拟。

## 目录结构

```
├── Start-BrightBeacon.ps1              # 主脚本：启动 iBeacon 广播
├── 相关文档/
│   ├── BrightBeacon_操作文档.md         # 操作指南（运行方法、参数修改、常见问题）
│   └── Start-BrightBeacon-修改过程总结.md # 脚本修改过程记录
├── README.md
└── .gitignore
```

## 快速开始

```powershell
powershell -ExecutionPolicy Bypass -File "Start-BrightBeacon.ps1"
```

详见 `相关文档/BrightBeacon_操作文档.md`。

## 免责声明

仅用于已授权的测试环境。请勿用于绕过考勤、签到、门禁、定位、访问控制或其他未授权场景。
