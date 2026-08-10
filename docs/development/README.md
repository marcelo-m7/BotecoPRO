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
and product diagnostics.
