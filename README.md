# Windows 系统维护

[English](README.en.md) | 中文 | [项目主页](https://vyvyc.github.io/windows-system-maintenance/)

用于基于证据的 Windows 磁盘清理与启动项优化。所有修改流程都先执行只读检查，生成带编号的安全清单，等待用户一次 `确认` 或指定项目编号后批量执行。

## 一键发送给 Agent

### Codex

```text
请从 https://github.com/vyvyc/windows-system-maintenance 安装 Codex Skill 到 $CODEX_HOME/skills/windows-system-maintenance。

安装后，请使用 $windows-system-maintenance：
1. 先只读检查本机磁盘和开机启动项。
2. 执行安全检查，生成带编号的审阅清单。
3. 说明每项动作、路径、大小、风险和预计影响。
4. 停止并等待我回复一次“确认”或指定编号，再一次性执行。
```

### DeepSeekHarness / 通用 Agent

```text
请把 https://github.com/vyvyc/windows-system-maintenance 作为当前任务可用的 Windows 系统维护 Skill。优先读取 SKILL.zh-CN.md、references/review-gate.zh-CN.md 和对应中文策略文件。

先只读检查本机磁盘与开机启动项，生成带编号的安全清单；说明路径、大小、风险与保留项。然后停止，等待我回复一次“确认”或指定编号后再批量执行，不要逐项重复询问。
```

### PowerShell

```powershell
$dest = "$HOME\.codex\skills\windows-system-maintenance"
if (Test-Path "$dest\.git") {
  git -C $dest pull --ff-only
} else {
  git clone https://github.com/vyvyc/windows-system-maintenance $dest
}
pwsh -NoProfile -File "$dest\scripts\audit-windows.ps1"
```

在线主页提供相同的“一键复制”按钮：[打开主页](https://vyvyc.github.io/windows-system-maintenance/)。

## 核心原则

- 用户只要求检查时，保持只读。
- 删除、停用或卸载前，先展示准确目标、影响、风险和状态。
- 一次授权即可执行整批项目，不逐项重复询问。
- 用户选择“暂停但以后还要用”时，优先改为 `Manual`，不卸载、不删除配置。
- 不手动删除 `WinSxS`、`Windows\Installer`、分页文件等受保护系统数据。
- 软件卸载必须验证产品状态、服务与残留路径。

## 语言切换

- 中文请求或“中文模式”：使用 [SKILL.zh-CN.md](SKILL.zh-CN.md)。
- 英文请求：使用 [SKILL.md](SKILL.md)。
- 中文策略参考：
  - [磁盘清理策略](references/cleanup-policy.zh-CN.md)
  - [启动项优化策略](references/startup-policy.zh-CN.md)
  - [审阅闸门](references/review-gate.zh-CN.md)

## 主要工具

### `scripts/audit-windows.ps1`

只读检查卷容量、顶层目录、已知缓存、受保护目录和大型文件。候选项目会获得审阅编号。

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -OutputPath "$env:TEMP\windows-maintenance-audit.json"
```

只扫描指定盘：

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -DriveLetters D,E -LargeFileGB 2
```

### `scripts/audit-startup.ps1`

检查 Run/RunOnce、StartupApproved、启动文件夹、登录/开机计划任务、第三方自动服务、失效路径和进程内存。每个条目都带审阅编号。

```powershell
pwsh -NoProfile -File scripts/audit-startup.ps1 -OutputPath "$env:TEMP\startup-audit.json"
```

### `scripts/set-service-mode.ps1`

在 Automatic、Manual、Disabled 之间调整服务启动类型，并可同时停止服务。

```powershell
pwsh -NoProfile -File scripts/set-service-mode.ps1 -ServiceName MySQL80 -StartMode Manual -StopNow
```

## 安装

把整个目录放入：

```text
%CODEX_HOME%\skills\windows-system-maintenance
```

如果没有设置 `CODEX_HOME`，使用 `%USERPROFILE%\.codex\skills`。

## 安全原则

审计脚本只读。清理、服务调整和卸载均只处理用户明确批准的目标，并保留配置与可恢复信息。

## 许可证

MIT
