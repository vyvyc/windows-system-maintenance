# Windows System Maintenance

English | [中文](README.md) | [项目主页](https://vyvyc.github.io/windows-system-maintenance/)

A Codex skill and audit toolkit for evidence-based Windows storage cleanup and startup optimization.

The skill is intentionally audit-first:

- Read-only by default when the user asks to inspect.
- Mutating workflows have one review gate: present a numbered safety-checked list, wait for one `确认` or explicit item IDs, then execute the entire approved batch without item-by-item re-confirmation.
- Exact, explicitly named targets for cleanup or service changes.
- Configuration and user data are preserved when software is only being paused.
- Startup changes distinguish `Manual` from `Disabled`.
- Protected Windows stores are identified instead of being deleted blindly.
- Vendor uninstall verification includes product state, services, and residual paths.

## Included tools

### `scripts/audit-windows.ps1`

Reports fixed-volume usage, top-level directory sizes, known cache paths, protected maintenance paths, and large files.
Review candidates receive stable IDs within the generated JSON report and are classified as ready or protected.

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -OutputPath "$env:TEMP\windows-maintenance-audit.json"
```

Limit a scan to selected drives:

```powershell
pwsh -NoProfile -File scripts/audit-windows.ps1 -DriveLetters D,E -LargeFileGB 2
```

### `scripts/audit-startup.ps1`

Reports Run/RunOnce entries, StartupApproved state, Startup folder items, logon/boot scheduled tasks, automatic third-party services, missing executable targets, and current process memory where measurable.
Each entry receives a review ID for a single-confirmation batch or partial selection.

```powershell
pwsh -NoProfile -File scripts/audit-startup.ps1 -OutputPath "$env:TEMP\startup-audit.json"
```

### `scripts/set-service-mode.ps1`

Changes a service between Automatic, Manual, and Disabled while optionally stopping it. Use `Manual` when the application should remain available for later use.

```powershell
pwsh -NoProfile -File scripts/set-service-mode.ps1 -ServiceName MySQL80 -StartMode Manual -StopNow
```

## Installation

Copy this directory into the Codex skills directory:

```text
%CODEX_HOME%\skills\windows-system-maintenance
```

If `CODEX_HOME` is unset, use `%USERPROFILE%\.codex\skills`.

## Safety

The audit scripts are read-only. Cleanup execution and service changes always require explicit user intent and appropriate administrative rights.

## License

MIT
