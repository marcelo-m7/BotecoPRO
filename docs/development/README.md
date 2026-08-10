# Development guide

## Checkout

```bash
git clone --recurse-submodules https://github.com/marcelo-m7/BotecoPRO.git
cd BotecoPRO
```

The mobile submodule is pinned to a published commit on the matching
`feat/odoo-online-mvp` branch. Do not manually point it at a local commit.

## Local configuration

Create `.env.local` with local-only values:

```env
ODOO_ONLINE_URL=
ODOO_ONLINE_USERNAME=
ODOO_ONLINE_API_KEY=
```

Never commit this file or use its values in tests, logs, screenshots or CI.

## Flutter checks

```bash
make mobile-get
make mobile-analyze
make mobile-test
```

The Odoo smoke flow is opt-in, read-only and must be run locally after an API
key has been entered. It reports only sanitized version, identity, company, POS
and product diagnostics:

```bash
set -a
. ./.env.local
set +a
(cd apps/mobile && flutter test test/odoo_live_smoke_test.dart)
```

It never runs in CI and must not be redirected to a log or artifact containing
environment values.

## Flutter structure

```text
lib/models/            application data; demo types live in legacy/
lib/services/odoo/     JSON-2 client and connection/catalog/POS services
lib/services/storage/  credentials, snapshot and draft persistence
lib/providers/         session, catalog and cart state
lib/pages/             connected and explicit demo screens
lib/widgets/           reusable presentation
```

`main.dart` is the composition root: it creates the shared storage/runtime
dependencies and wires the three providers. Pages do not build JSON-2 payloads
or access device storage. The connected route never imports demo business
models.

## Offline read validation

After one complete successful synchronization, interrupt networking and reopen
the app with the same instance, user, company and POS. The catalog must remain
available with `Offline · Dados locais` and the last synchronization time. A
different context must not restore it. The local draft comanda must survive an
app restart, but is never represented as synchronized or queued for Odoo.
