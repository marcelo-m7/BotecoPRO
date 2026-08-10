# ADR: direct Odoo Online JSON-2 integration

## Decision

BotecoPRO native Flutter clients call Odoo Online directly over HTTPS using
Odoo's JSON-2 external API and a bearer API key belonging to the Odoo user.
There is no BotecoPRO backend or custom authentication layer in the MVP.

## Authentication

JSON-2 authenticates with `Authorization: bearer <api-key>`. The username is
stored as connection metadata and compared with the authenticated
`res.users.login`; it is not a second password-based identity system.

Connection metadata is stored in preferences. The API key is stored only in
`flutter_secure_storage`. Disconnect removes only BotecoPRO connection keys.

## Request contract

```text
GET  /web/version
POST /json/2/res.users/context_get
POST /json/2/res.users/search_read
POST /json/2/res.company/search_read
POST /json/2/pos.config/search_read
POST /json/2/pos.category/search_read
POST /json/2/product.product/search_read
```

Calls use explicit domains, fields, company context and limits. The app never
passes raw server tracebacks to users and never logs request headers or bodies.

## Scope boundary

The initial connection is read-only. `pos.session`, `pos.order`, payments,
stock moves and accounting writes require a separate design and functional
validation. Flutter Web is not a target for this credential model. Android,
iOS and native POS are the supported clients.

## Consequences

Odoo standard models, ACLs, record rules and multi-company context become the
source of truth. Custom Python addons are not a dependency because Odoo Online
does not support installing them. The former `botecopro_api` and OpenAPI
contract are historical designs and are not active integration contracts.
