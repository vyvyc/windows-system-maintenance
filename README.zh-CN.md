# Windows 系统维护 Skill

用于基于证据的 Windows 磁盘清理与启动项优化。英文主说明见 [README.md](README.md)。

所有修改流程只需要一次最终确认：先只读检查并生成带编号的安全清单，用户回复一次 `确认` 或指定项目编号后，直接批量执行，不再逐项询问。

## 语言切换

- 英文请求：使用 [SKILL.md](SKILL.md)。
- 中文请求或用户说“中文模式”：使用 [SKILL.zh-CN.md](SKILL.zh-CN.md)。
- 中文策略参考：
  - [磁盘清理策略](references/cleanup-policy.zh-CN.md)
  - [启动项优化策略](references/startup-policy.zh-CN.md)

## 主要工具

### `scripts/audit-windows.ps1`

只读检查卷容量、顶层目录、已知缓存、受保护目录和大型文件。
生成的 JSON 报告会为候选项目分配编号，并标记是否可执行或受保护。

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -OutputPath "$env:TEMP\windows-maintenance-audit.json"
```

只扫描指定盘：

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -DriveLetters D,E -LargeFileGB 2
```

### `scripts/audit-startup.ps1`

检查 Run/RunOnce、StartupApproved、启动文件夹、登录/开机计划任务、第三方自动服务、失效路径和可测得的进程内存。
每个条目都带审阅编号，可用于一次性确认整批或只选择部分项目。

```powershell
pwsh -NoProfile -File scripts/audit-startup.ps1 -OutputPath "$env:TEMP\startup-audit.json"
```

### `scripts/set-service-mode.ps1`

在 Automatic、Manual、Disabled 之间调整服务启动类型，并可同时停止服务。以后还会使用软件时优先选择 `Manual`。

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

审计脚本只读。清理要求只处理用户明确列出的目标；服务调整、删除和卸载均需明确授权，并保留可恢复的配置。

## 许可证

MIT
