# Disk Cleanup Policy

## Contents

- Classification
- Evidence to collect
- Deletion protocol
- Windows-specific cautions
- Vendor uninstall notes

## Classification

Use these labels in audit reports:

| Label | Examples | Default action |
|---|---|---|
| Regenerable cache | browser HTTP/code/shader caches, updater downloads, package-manager caches | Safe to remove after confirming affected apps are closed |
| Rebuild cache | Gradle caches, IDE indexes, model caches | Removable, but next use may require a long download or rebuild |
| Media or installer | ISOs, ZIPs, extracted setup bundles | Delete only when the user confirms they no longer need installation or repair media |
| User data | documents, desktop files, recordings, VMs, projects, datasets | Never delete from a generic "cleanup" request; require exact paths |
| Protected system | `Windows\WinSxS`, `Windows\Installer`, pagefile, system-managed package stores | Do not delete manually |

Prefer `Manual` service state over `Disabled` when the user says they may use the software again.

## Evidence to Collect

- Capacity and free space for every fixed volume.
- Top-level directory sizes and file counts.
- Largest files when identifying VM disks, recordings, ISOs, or archives.
- ZIP member names when checking whether a ZIP duplicates an extracted directory.
- Modification times for caches and installers.
- Process state before deleting application-owned cache directories.
- Current installed-product state before removing software directories.

Report exact measurements as observed facts. Label cleanup totals as estimates.

## Deletion Protocol

1. Resolve every user-selected target to an absolute path.
2. Check that the target is not a reparse point unless removing only the link is intended.
3. Verify the target is not a parent of unrelated data.
4. Stop only applications or services that hold the target open.
5. Assign a review ID and mark each target `Ready`, `Needs decision`, `Protected`, or `Rejected`.
6. Present the review list and wait for the user's final `确认` or explicit IDs.
7. Revalidate the selected IDs immediately before acting.
8. Use that single authorization for the whole selected batch; do not ask again item by item.
9. Prefer deleting the exact listed directories and files, never a drive root or broad glob.
10. Preserve configuration and user databases when the request is only to stop autostart.
11. After deletion, verify each target and report leftover locked files.

For batch deletion, keep a list of `{label, absolute path}` objects and delete sequentially. Do not construct broad commands such as `Remove-Item "$env:USERPROFILE\*"`.

## Windows-Specific Cautions

- Use `DISM /Online /Cleanup-Image /AnalyzeComponentStore` for read-only component-store analysis, then use supported component cleanup only with authorization.
- Do not delete `Windows\Installer`; it is required for repair and uninstall.
- Do not delete `C:\ProgramData\Package Cache`; application installers may depend on it.
- Do not delete or resize `pagefile.sys` or `swapfile.sys` as generic cleanup.
- Do not delete `.vscode\extensions` as a cache. Review or uninstall extensions instead.
- Clear browser caches without deleting bookmarks, passwords, cookies, profiles, or extension data unless explicitly requested.
- For product caches such as GPU driver update artifacts, verify the cached installer is not currently installing.
- For duplicate archives, inspect ZIP entries and compare names/sizes with the extracted copy before recommending deletion.

## Vendor Uninstall Notes

- Query both the normal and WOW6432Node uninstall registry views.
- Use `WindowsInstaller.Installer.ProductState()` to distinguish installed MSI products.
- Stop known vendor services before launching an uninstaller.
- Windows Installer serializes operations. Do not start another product uninstall while a prior transaction is suspended.
- Do not interpret an uninstaller launching successfully as proof of removal.
- If a vendor UI requires an interactive elevated session, hand control to the user or use a documented silent switch that has been verified.
- Verify again after completion; report reboot requirements and remaining registered components.
