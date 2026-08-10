# BotecoPRO – Agent Guidelines

## Architecture

The MVP is a native Flutter client connected directly to Odoo Online through
the official JSON-2 external API:

```text
Flutter → HTTPS/JSON-2 → Odoo Online
```

There is no BotecoPRO backend, REST intermediary, Supabase project, gateway,
JWT service or mandatory Python addon. Odoo is the source of truth for business
data and permissions.

The first vertical is read-only: connection, `res.users`, `res.company`,
`pos.config`, `pos.category` and POS products. Writes, offline outbox and device
provisioning are later milestones.

## Safety rules

1. Study the relevant source and Odoo model documentation before changing code.
2. Use Odoo standard models first; do not duplicate `res.partner`, `pos.order`,
   `product.product` or other standard models.
3. Do not add custom addons as an Odoo Online MVP requirement.
4. Never edit Odoo core.
5. Never commit `.env`, `.env.local`, API keys, passwords or tokens.
6. Never print API keys in logs, exceptions, analytics, fixtures or tests.
7. Keep metadata in ordinary preferences and the API key only in
   `flutter_secure_storage`.
8. All Odoo calls go through the central Flutter `OdooClient`; widgets do not
   construct JSON-2 payloads.
9. Preserve offline/demo code while it is explicitly isolated from connected
   Odoo mode.
10. Run `flutter analyze --fatal-infos` and relevant tests before concluding.
11. Use small Conventional Commits.
12. Update architecture and roadmap documentation with behavior changes.

## Repository layout

```text
apps/mobile/       Flutter submodule and source of the mobile app
apps/website/      Website submodule, retained independently
docs/architecture/ Odoo integration decisions and domain mapping
docs/roadmap/      Future cache, writes and provisioning milestones
docs/archive/      Superseded intermediary API/addon designs
```

The `apps/mobile` gitlink must always reference a commit already pushed to the
`BotecoPro-app` remote. The `.gitmodules` branch is advisory; the gitlink is
the reproducible checkout reference.

## Secrets and local development

Use local-only values:

```env
ODOO_ONLINE_URL=
ODOO_ONLINE_USERNAME=
ODOO_ONLINE_API_KEY=
```

The smoke test is opt-in, read-only and never runs in CI. Historical credentials
found in old app code or commits must be revoked/rotated; deleting a file does
not invalidate a previously exposed key.

## Commit prefixes

```text
feat: fix: docs: refactor: test: chore: ci:
```
