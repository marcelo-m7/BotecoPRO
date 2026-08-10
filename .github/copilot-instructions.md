# BotecoPRO Copilot Instructions

The current integration target is:

```text
Flutter native → Odoo JSON-2 → Odoo Online saas~19.4+
```

Do not introduce a BotecoPRO API, FastAPI, Supabase, middleware, gateway or
custom authentication service. Use the Odoo user/API-key identity and standard
ACLs/record rules. Do not assume that Python addons can be installed on Odoo
Online.

For Flutter changes:

- call Odoo only through `lib/core/odoo/odoo_client.dart` and repositories;
- keep the API key in `flutter_secure_storage` only;
- use explicit domains, fields, limits and pagination;
- keep native Android/iOS/POS as the MVP target; Web is not a credential-safe
  target for this flow;
- keep the old local screens only in the explicit debug demo mode;
- do not implement POS/order/payment writes until their Odoo lifecycle is
  validated.

For repository changes:

- update `docs/architecture/` and `docs/roadmap/` with architecture changes;
- never point `apps/mobile` at a local-only commit;
- preserve `.env.local` and never expose its values;
- use small Conventional Commits and run Flutter analysis/tests.
