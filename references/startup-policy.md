# Startup Optimization Policy

## Scope

Inspect all common Windows startup mechanisms before ranking impact:

- User and machine Startup folders.
- HKCU and HKLM `Run` and `RunOnce` values, including WOW6432Node.
- `StartupApproved` state for Run entries and Startup folder shortcuts.
- Logon and boot scheduled tasks.
- Automatic services outside the Windows system directories.
- UWP/package startup behavior when the Windows Startup Apps UI is used.

## Interpretation

`Get-CimInstance Win32_StartupCommand` lists configured entries but does not reliably mean an entry is currently enabled. Combine it with `StartupApproved`; a first byte of `02` is normally enabled and `03` normally disabled. If no override exists, treat the entry as configured and requiring verification in Windows Settings.

Do not describe a service as "impacting boot" solely because it has `StartType=Automatic`. Check:

- Current state.
- Delayed auto-start flag.
- Whether another process/service depends on it.
- Installed hardware/software still requiring it.
- Current resident memory and sustained CPU/GPU use when measurable.

## Recommendation Classes

### Usually safe to disable

- Update-only agents and tray utilities not required for device operation.
- Game launchers and animated wallpapers when not needed every session.
- Missing executables left behind after product removal.
- Cloud-drive clients, remote-control agents, VPN/proxy clients, emulators, and development database services only after confirming the user does not require them at logon.

### Usually keep

- Windows security and Defender services.
- Audio, network, storage, display, input, and power/thermal drivers.
- Laptop vendor control services required for fan curves or performance modes.
- Licensing services while licensed software is actively used.

### Manual is preferred over Disabled

When the user says they may use the software later:

1. Stop the service now if permitted.
2. Set `StartType=Manual`.
3. Remove only the unnecessary tray or launcher startup entry.
4. Preserve installation files, configuration, data, and service registration.

Some protected services report `NOT_STOPPABLE`. If startup has been set to `Manual`, tell the user that the running instance ends only at shutdown/restart.

## Verification

Before changing services or startup entries, present a numbered review list and wait for the user's single `确认` or explicit IDs. Include whether each item is required, contextual, broken, or safe to disable. After that authorization, do not ask again for the same items. Do not start a second mutation pass from newly discovered items without a new review.

Report:

- Item and mechanism: Run, Startup folder, task, or service.
- Enabled/disabled/manual status.
- Whether the executable exists.
- Current process count and memory when available.
- Whether the dependency is required for hardware or software operation.

After changes, verify service `Status` and `StartType`, startup key/task state, and process state.
