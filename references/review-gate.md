# Review Gate

Use this gate for deletion, service changes, startup changes, uninstalls, registry changes, or any other persistent system mutation.

Use exactly one user authorization step after the audit. Do not ask the user to confirm the batch, then individual targets, then execution again.

## Candidate states

- `Ready`: exact target, safe interpretation, and no unresolved runtime lock.
- `Needs decision`: user data or context-dependent software that the user must explicitly keep or remove.
- `Protected`: Windows repair, recovery, licensing, or other data that this workflow must not delete directly.
- `Rejected`: target is unsafe, ambiguous, outside the requested scope, or currently in use.

Only `Ready` items may be executed by the word `确认`.

## Present the review

Use a compact numbered table:

| ID | Planned action | Exact target | Size/state | Risk and consequence |
|---|---|---|---|---|
| `C01` | Delete | `D:\Example\cache` | 2.3 GB | Rebuilds automatically; service may pause |
| `S01` | Stop + Manual | `MySQL80` | Running / Automatic | Applications using MySQL stop until manually started |

After the table:

1. State the total estimated reclaim or effect.
2. List items excluded by the safety check and why.
3. Tell the user how to choose a subset.
4. Ask for one final authorization and stop the turn without mutating anything.

## Accepted final commands

- `确认`: execute every current `Ready` item from the latest list.
- `执行 C02,C05` or `只执行 S01`: execute only the named current items.
- A natural-language instruction that unambiguously identifies the same current items is also acceptable.

If the selection is ambiguous, do not execute. Ask one concise question or restate the candidate IDs.

After a valid final command, do not request another confirmation for those items.

## Revalidation immediately before execution

- Confirm the target is still the same object.
- Recompute size/state when practical.
- Recheck that VMs, services, or applications holding it are not running.
- Confirm protected items were not included.
- Confirm no new candidate was silently added.

If a target vanished or no longer matches the approved object, skip that item, execute the remaining approved items, and report the skipped item after completion. If the requested scope itself is ambiguous, do not execute the ambiguous part and explain why; do not create a second confirmation round for already-clear items.

## Completion

Report per-item success, leftovers, preserved configuration, and reboot requirements in one completion summary. Do not claim all items succeeded solely because an uninstaller or deletion command launched.
