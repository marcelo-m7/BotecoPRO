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
POST /json/2/restaurant.floor/search_read
POST /json/2/restaurant.table/search_read
POST /json/2/res.currency/read
POST /json/2/product.pricelist/read
POST /json/2/pos.session/search_read
POST /json/2/pos.payment.method/read
```

Company-scoped business calls use explicit domains, fields, company context and
limits. The app never passes raw server tracebacks to users and never logs
request headers or bodies. The connection diagnostic also counts the POS
catalog with the same domain used by the paginated product list. A zero count is
shown as a catalog-readiness warning; it does not turn a valid authentication
into a connection failure.

## Operational UI boundary

In connected mode, POS categories and `product.product` variants are displayed
directly in the Flutter catalog. The operator can filter, search, inspect and
add those real products to a local non-fiscal cart, optionally associated with
a read-only Odoo Restaurant table. Changing company or POS clears that local
cart so contexts never mix.

A schema-v1 snapshot preserves the fully loaded catalog and the Restaurant data
that was readable after a successful synchronization. Catalog completeness is
required before the snapshot is published. Restaurant reads are optional and
currently tolerate a missing model or insufficient read permission by storing
an empty Restaurant context. On network failure only, the exact same
instance/user/company/POS can operate from that snapshot with an explicit
offline indicator and synchronization timestamp.

The local draft comanda is persisted separately and reconciled against the next
fresh catalog. Changed and unavailable items remain visible. M7 keeps one
snapshot and one draft slot on the device; selecting another context discards a
non-matching slot rather than mixing tenants. Neither snapshot nor draft
contains the API key, and neither is a queued Odoo transaction.

The selected POS has a live read-only operational profile. Currency and
pricelist metadata may be retained for offline value presentation. Session
ownership, session IDs/states and payment methods stay in memory only and are
hidden offline because those values become stale and can include personal or
operational data. Rescue sessions are excluded and only a session whose exact
state is `opened` can ever satisfy a future write-readiness check.

The displayed price is the explicit numeric `lst_price` catalog value returned
by Odoo; an absent or malformed value fails synchronization rather than being
invented as zero. It and
its presentation currency are informative only: M7 does not prove POS
pricelist, fiscal, tax or transactional pricing and Flutter does not implement
an independent pricing engine. Those inputs and the standard POS contract must
be validated before any order write.

## Scope boundary

The implemented integration is read-only. Reading session metadata for an
operational profile does not authorize creating, opening or closing a
`pos.session`. Creating or updating `pos.order`, payments, stock moves and
accounting records requires separate design and functional validation. Flutter
Web is not a target for this credential model. Android, iOS and native POS are
the supported clients.

Fiscal master-data reconciliation is also a release gate. Documents whose
recipient does not match the selected Odoo company remain draft historical
candidates until their legal relationship is evidenced; the mobile MVP never
posts, pays, reconciles, cancels or edits accounting entries.
The local cart does not create `pos.order`, payments, stock moves or invoices.
The researched write boundary is recorded in
[`adr-m8-controlled-pos-write.md`](adr-m8-controlled-pos-write.md) and remains
blocked.

## Flutter code boundary

The mobile application uses a deliberately simple responsibility-based
structure:

```text
pages/widgets → providers → services → OdooClient → Odoo JSON-2
                         ↘ storage services
```

- application models are transport-independent and expose no raw JSON-2 maps;
- `OdooSessionProvider` owns authentication and company/POS context;
- `CatalogProvider` owns synchronization, snapshot freshness and Restaurant
  reads;
- `CartProvider` owns only the context-bound local draft and persistence;
- Odoo transport, mapping and persistence never live in widgets;
- demo models remain isolated under `models/legacy`.

`lib/core/odoo` and the parallel `lib/features` screen tree were removed. They
had become duplicate, mixed-responsibility containers. No repository layer was
retained because the connection, catalog and POS services already define the
cohesive external-system boundary needed by this MVP.

## Consequences

Odoo standard models, ACLs, record rules and multi-company context become the
source of truth. Custom Python addons are not a dependency because Odoo Online
does not support installing them. The former `botecopro_api` and OpenAPI
contract are historical designs and are not active integration contracts.
