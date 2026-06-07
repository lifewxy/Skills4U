---
name: orchard
description: "Use the local `orchard` CLI to interact with macOS Apple apps and services from Codex: Calendar, Reminders, Clock, Mail, Contacts, Notes, Music, Weather, Messages, and Location/Maps. Use when a task asks to read or manage local calendar events, reminders, Apple Mail, contacts, notes, iMessage/SMS, Apple Music playback/library, weather, current time/timezones, geocoding, routes, or current location."
metadata:
  version: "0.1.0"
  updated: "2026-06-07"
  tested_with:
    orchard_cli: "0.5.1"
---

# Orchard

## Quick Start

Use `orchard` for local Apple-app automation on macOS.

Check availability first:

```bash
command -v orchard && orchard --version
```

Prefer `--json` for machine-readable output. Orchard 0.5.1 usually returns an outer JSON envelope:

```json
{"output":"...possibly another JSON string...","success":true}
```

The `output` value may be plain text, JSON text, or prose followed by JSON such as `Found 2 events:\n{...}`. If `output` contains JSON, strip text before the first JSON object/array and parse the nested payload before reasoning over records.

For the full command matrix, read `references/commands.md`.

## Known Pitfalls

- Check leaf-command help with `orchard <domain> <command> --help`, not `orchard help <domain> <command>`. The latter falls back to top-level help in 0.5.1.
- In zsh loops, never pass a multi-word command through a scalar like `orchard $cmd`; zsh keeps it as one argument. Use an array, or `eval` only for trusted static command strings.
- `orchard mail read` in 0.5.1 has no documented `--from`, `--to`, or `--offset`. For a time window, read enough recent messages with `--limit`, filter `date_sent` locally, and state possible truncation when results hit the limit.
- Treat help output and the installed CLI as source of truth. If this skill and CLI disagree, run `orchard <domain> <command> --help` and adapt.

## Core Rules

- Use ISO 8601 timestamps for all date ranges. Include timezone offsets when the user means local time, e.g. `2026-06-03T08:00:00+08:00`.
- Convert relative dates before calling Orchard. "Yesterday 08:00" must become a concrete timestamp.
- Before creating calendar events or reminders, list calendars/lists and choose the right writable target. Do not dump everything into a default list/calendar unless the user explicitly asks.
- Before update/delete/mark/cancel operations, read the target and capture its ID.
- Treat destructive operations as real local mutations. For deletes, bulk updates, sending mail/messages, and scheduled sends, confirm intent unless the user explicitly requested the action.
- Never print huge email bodies or private data unnecessarily. Fetch summaries first, then read full content only for messages that matter.

## Common Workflows

### Daily Context

```bash
orchard clock time --timezone Asia/Shanghai --json
orchard weather get --location Jinan --granularity daily --start-date YYYY-MM-DD --end-date YYYY-MM-DD --json
orchard calendar info --type events --from YYYY-MM-DDT00:00:00+08:00 --to YYYY-MM-DDT00:00:00+08:00 --json
orchard reminder info --type reminders --status incomplete --json
```

When summarizing reminders, filter stale/completed/noisy records yourself if Orchard returns more than requested.

### Mail Triage

```bash
orchard mail refresh --json
orchard mail read --type list --limit 100 --json
orchard mail read --type content --message-id MESSAGE_ID --json
```

Orchard 0.5.1 mail listing has `--limit`, `--mailbox`, and `--account`, but no documented `--from`, `--to`, or `--offset`. To cover a time window, request enough recent messages and filter `date_sent` locally. If the result count equals the limit, say the scan may be truncated instead of pretending coverage is complete.

Only fetch full email bodies for likely important mail: accounts, billing, support, customer, legal, platform review, security, collaboration, or anything the user asked to inspect.

### Calendar And Reminder Writes

```bash
orchard calendar info --type calendars --json
orchard calendar create --title "Call" --start 2026-06-03T15:00:00+08:00 --end 2026-06-03T15:30:00+08:00 --calendar-id CALENDAR_ID --alarms 15 --json

orchard reminder info --type lists --json
orchard reminder create --title "Follow up" --list-id LIST_ID --due-date 2026-06-03T18:00:00+08:00 --priority 5 --json
```

Use `priority 0-9`; higher numbers are more important in Orchard output. Mark complete with:

```bash
orchard reminder update --reminder-id REMINDER_ID --completed true --json
```

### Notes And Contacts

Search before creating duplicates:

```bash
orchard contacts search --query "Alice" --limit 10 --json
orchard notes search --query "project name" --limit 20 --json
```

Notes content is HTML for create/update. If the user gives Markdown, convert it to simple HTML first.

### Messages

```bash
orchard messages read --type chats --query "search term" --limit 20 --json
orchard messages read --type messages --chat "+15551234567" --limit 50 --json
orchard messages send --to "+15551234567" --text "Text here" --service iMessage --json
```

Confirm before sending unless the user directly instructs sending exact text.

## Troubleshooting

- If a command asks for macOS privacy permissions, tell the user which app/service needs permission and retry after permission is granted.
- If a command returns `Orchard.app is not running`, start it with `open -a Orchard`, wait a few seconds, then retry once.
- If a command returns `Invalid response from Orchard.app`, treat it as an Orchard.app bridge/permission/runtime issue, not necessarily a CLI syntax issue. Retry once, then ask the user to check that Orchard.app is running and has the relevant macOS privacy permissions.
- If Apple Mail, Calendar, or Reminders data looks stale, run the relevant refresh/list command again and state the timestamp of the scan.
- If `--json` output contains a long HTML email body, summarize only the relevant parts; do not paste the entire body.
- If a flag is not accepted, trust `orchard <domain> <command> --help` for the installed version and adapt.
