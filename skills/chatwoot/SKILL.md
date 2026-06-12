---
name: chatwoot
description: Use the official Chatwoot CLI to inspect and operate Chatwoot conversations, messages, contacts, inboxes, labels, teams, help center articles, webhooks, reports, and raw Application API paths. Use when Codex needs to call Chatwoot APIs, work with a self-hosted Chatwoot domain, fetch customer feedback, summarize recent conversations, send replies or private notes, assign/label/close conversations, or guide a user through installing and authenticating the Chatwoot CLI.
---

# Chatwoot

## Rule

Use the official `chatwoot` CLI. If the CLI is missing or unauthenticated, stop and guide the user through install/auth first.

Do not bypass the CLI with raw REST calls, Rails runner, database queries, or server-side container access unless the user explicitly asks for a fallback path after seeing the install/auth instructions. Boss picked the CLI route; respect it.

For self-hosted deployments, prompt for or discover:

- Base URL: the Chatwoot instance URL, for example `https://chatwoot.example.com`
- Account ID: the numeric account ID from the Chatwoot dashboard URL or `chatwoot auth status`

Never store or print the API access token in skill files, docs, shell history examples, or final answers.

## Setup Check

1. Check whether the CLI exists:

```bash
command -v chatwoot && chatwoot --version
```

2. If missing, guide the user to install:

```bash
curl -fsSL https://chwt.app/install-cli | sh
```

After install, ask the user to restart the shell if `chatwoot` is still not found, then run:

```bash
chatwoot --version
chatwoot auth login
```

3. Authenticate:

```bash
chatwoot auth login
```

Tell the user to enter:

- Base URL: their self-hosted Chatwoot URL, for example `https://chatwoot.example.com`
- API Key: Profile Settings -> Personal Access Token / API access token
- Account ID: the number in the Chatwoot dashboard URL

The CLI supports self-hosted domains because `auth login` asks for a Base URL and validates credentials against that instance.

## Config

Official CLI persistence:

- Non-secret config: `~/.chatwoot/config.yaml`
- API key: OS keyring
- Headless/CI override: `CHATWOOT_API_KEY`

Useful checks:

```bash
chatwoot auth status
chatwoot config path
chatwoot config view
```

Use `CHATWOOT_API_KEY` only for CI/headless sessions where keyring access is unavailable. Prefer the keyring on the user's Mac.

Do not confuse `chatwoot` with `cwctl`. `cwctl` manages self-hosted server operations; `chatwoot` is the customer-support API CLI.

## Common Workflows

List open conversations:

```bash
chatwoot convs
```

List all conversations in an inbox or assigned to anyone:

```bash
chatwoot convs --assignee all --inbox 5
```

Search conversations by message content:

```bash
chatwoot convs --query "refund"
```

View a conversation:

```bash
chatwoot conv 123
```

Reply or add a private note:

```bash
chatwoot conv 123 reply "Looking into it"
chatwoot conv 123 reply "Internal context" --private
```

Change status, assignee, labels, or priority:

```bash
chatwoot conv 123 resolve
chatwoot conv 123 open
chatwoot conv 123 pending
chatwoot conv 123 assign --agent me
chatwoot conv 123 assign --team 7
chatwoot conv 123 label billing,urgent
chatwoot conv 123 priority urgent
```

List supporting objects:

```bash
chatwoot inboxes
chatwoot agents
chatwoot labels
chatwoot teams
chatwoot me
```

Use JSON for automation:

```bash
chatwoot convs -o json
chatwoot convs -q
```

Use raw Application API paths through the CLI when the noun command does not cover the endpoint:

```bash
chatwoot api /conversations/123
chatwoot api -X PATCH /conversations/123 --data '{"status":"open"}'
```

The raw API path expands under `/api/v1/accounts/<account_id>`.

## Customer Feedback

For daily customer feedback summaries:

1. Use `chatwoot convs -o json` or `chatwoot api /conversations?... -o json` to get candidate conversations.
2. Prefer active/recent conversations, then inspect individual conversations.
3. Treat customer-originated messages as `incoming`; agent replies are `outgoing`; private notes are not customer feedback.
4. For precise date filters or endpoints not exposed by noun commands, use `chatwoot api` with `/conversations/filter` and JSON payloads.

Read `references/cli.md` when command syntax, install details, or API coverage is needed.
