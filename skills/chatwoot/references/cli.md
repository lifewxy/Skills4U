# Chatwoot CLI Reference

## Official Evidence

The official Chatwoot CLI supports self-hosted domains. `chatwoot auth login` prompts for Base URL, API Key, and Account ID, validates credentials, stores non-secret config at `~/.chatwoot/config.yaml`, stores the API key in the OS keyring, and allows `CHATWOOT_API_KEY` as a CI/headless override.

Install command:

```bash
curl -fsSL https://chwt.app/install-cli | sh
```

Authentication:

```bash
chatwoot auth login
```

Config and status:

```bash
chatwoot auth status
chatwoot auth logout
chatwoot config path
chatwoot config view
```

Sources:

- `https://developers.chatwoot.com/cli`
- `https://github.com/chatwoot/cli`

## API Families

The stable Application API areas relevant to this skill:

- Profile: `GET /api/v1/profile`
- Account: get/update account
- Conversations: list, filter, create, show, update, status, priority, typing, custom attributes, labels, reporting events
- Messages: list/create/delete conversation messages
- Contacts: list, search, filter, create, show, update, delete, contact conversations, labels, contact inboxes
- Inboxes and inbox members
- Agents, teams, labels, canned responses
- Webhooks: list/create/update/delete
- Reports: v1 reporting events and v2 report summaries
- Help Center portals, categories, articles
- Agent bots, automation rules, custom attributes, custom filters, integrations, audit logs

Use noun commands when available. Use `chatwoot api` for less common endpoints.

## Raw API Examples

Profile:

```bash
chatwoot api /profile
```

Conversation details:

```bash
chatwoot api /conversations/123
```

Conversation filter:

```bash
chatwoot api -X POST /conversations/filter --data '{
  "payload": [
    {
      "attribute_key": "last_activity_at",
      "filter_operator": "is_greater_than",
      "values": ["2026-06-12"],
      "query_operator": null
    }
  ]
}'
```

Messages:

```bash
chatwoot api /conversations/123/messages
```

Webhooks:

```bash
chatwoot api /webhooks
chatwoot api -X POST /webhooks --data '{
  "name": "daily-feedback-events",
  "url": "https://example.com/chatwoot/webhook",
  "subscriptions": ["conversation_created", "message_created"]
}'
```

## Safety

Customer-visible writes include replies, status changes, assignments, labels, priority changes, and webhook creation/update/delete. Confirm intent before performing writes in production unless the user explicitly requested that exact action.

Never expose the API key. `chatwoot config view` masks it, but still avoid pasting full config output unless necessary.
