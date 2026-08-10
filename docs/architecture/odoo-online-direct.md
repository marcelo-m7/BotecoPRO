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
POST /json/2/product.product/search_count
POST /json/2/product.product/search_read
```

Calls use explicit domains, fields, company context and limits. The app never
passes raw server tracebacks to users and never logs request headers or bodies.
The connection diagnostic also counts the POS catalog with the same domain used
by the paginated product list. A POS whose category restriction returns zero
products is authenticated but not operationally ready.

## Operational UI boundary

In connected mode, POS categories and `product.product` variants are displayed
directly in the Flutter catalog. The operator can filter, search, inspect and
add those real products to a local non-fiscal cart, optionally associated with
a read-only Odoo Restaurant table. Changing company or POS clears that local
cart so contexts never mix.

The displayed price is the `lst_price` catalog value returned by Odoo. It is
informative only: POS pricelist, fiscal and transactional pricing are not
reimplemented by Flutter and will be validated before any order write.

## Scope boundary

The initial connection is read-only. `pos.session`, `pos.order`, payments,
stock moves and accounting writes require a separate design and functional
validation. Flutter Web is not a target for this credential model. Android,
iOS and native POS are the supported clients.

Fiscal master-data reconciliation is also a release gate. Documents whose
recipient does not match the selected Odoo company remain draft historical
candidates until their legal relationship is evidenced; the mobile MVP never
posts, pays, reconciles, cancels or edits accounting entries.
The local cart does not create `pos.order`, payments, stock moves or invoices.

## Consequences

Odoo standard models, ACLs, record rules and multi-company context become the
source of truth. Custom Python addons are not a dependency because Odoo Online
does not support installing them. The former `botecopro_api` and OpenAPI
contract are historical designs and are not active integration contracts.
