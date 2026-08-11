# ADR M8: controlled Odoo POS order write (research only)

Status: **proposed and blocked**. This ADR does not authorize writes.

## Context and evidence levels

Odoo 19 JSON-2 exposes public model methods and commits each call in its own SQL
transaction. Odoo explicitly recommends one business method for related writes,
especially reservations and payments. Therefore direct sequences of
`pos.order.create`, `pos.order.line.create` and `pos.payment.create` are rejected.

The inspected public Odoo 19 source defines `pos.order.sync_from_ui(orders)`. It
resolves an existing order by `uuid`, updates only draft orders and processes
each order through the server workflow used by the standard POS UI. Orders,
order lines and payments have unique UUID constraints. These properties make
`sync_from_ui` the standard-first **provisional candidate**, not an approved
integration contract.

Evidence must not be conflated:

| Evidence | What it proves | State |
|---|---|---|
| Odoo 19 JSON-2 documentation | authentication and one-transaction-per-call semantics | confirmed |
| Public Odoo 19 source pinned below | upstream `sync_from_ui`, UUID and lifecycle behavior | confirmed for that revision only |
| Authenticated `/doc` of the target database | exact methods, parameters and fields exposed by SaaS | pending |
| Authenticated read-only profile | selected session, currency, pricelist, payment methods and ACL context | implemented and confirmed by local read-only smoke |
| Sanitized standard frontend fixture | exact order payload and context used by the same SaaS version | pending |
| Disposable-database rehearsal | actual stock, payment, tax and accounting effects | pending |

The public 19.0 source does not by itself prove the exact Enterprise SaaS 19.4
contract. No write may be added until the instance `/doc`, standard frontend and
a disposable database agree on that contract.

Sources:

- [Odoo 19 JSON-2 API and transaction boundary](https://www.odoo.com/documentation/19.0/developer/reference/external_api.html)
- [Pinned Odoo 19 `pos.order` implementation](https://github.com/odoo/odoo/blob/36996c41d98e255a5ad873d40632b04cfbb79d68/addons/point_of_sale/models/pos_order.py)
- [Pinned Odoo 19 `pos.payment` implementation](https://github.com/odoo/odoo/blob/36996c41d98e255a5ad873d40632b04cfbb79d68/addons/point_of_sale/models/pos_payment.py)
- [Pinned Odoo 19 Restaurant order extension](https://github.com/odoo/odoo/blob/36996c41d98e255a5ad873d40632b04cfbb79d68/addons/pos_restaurant/models/pos_order.py)
- [Pinned Odoo 19 POS session implementation](https://github.com/odoo/odoo/blob/36996c41d98e255a5ad873d40632b04cfbb79d68/addons/point_of_sale/models/pos_session.py)
- [Odoo 19 POS pricing](https://www.odoo.com/documentation/19.0/applications/sales/point_of_sale/extra/pricing.html)
- [Odoo 19 Restaurant workflow](https://www.odoo.com/documentation/19.0/applications/sales/point_of_sale/restaurant.html)

## Proposed milestone boundary

M8 must not treat every POS write as one operation:

1. **M8a — restaurant draft rehearsal.** Create or update only an unpaid
   `pos.order` draft in a disposable database, with no payment. A draft can
   still occupy a table, update preparation state and emit POS notifications;
   it is an operational write even when it has no fiscal effect.
2. **M8b — paid order rehearsal.** Add validated pricing, taxes and supported
   payment methods. This can create stock, invoice and accounting effects and
   remains blocked until M8a and all fiscal gates pass.
3. **Session closing.** BotecoPRO does not close sessions in either rehearsal.
   Deferred stock, session journal entries and reconciliation stay under the
   standard Odoo operator workflow.

Neither M8a nor M8b is authorized against the production database by this ADR.

## Decisions and open gates

1. **Session requirement.** A payload references `session_id`. If that session is
   closing or closed, Odoo searches an opened session for the same POS and fails
   when none exists. M8 requires an explicitly opened standard `pos.session`;
   BotecoPRO will not open one implicitly.
2. **Session ownership.** `pos.session.user_id` identifies the Odoo user who
   opened it. This does not prove that the API-key user may write into another
   user's session. The authenticated user's ACL/record-rule access, the allowed
   ownership policy and the visible session owner must be validated explicitly.
3. **Multiple devices.** The source carries a `device_identifier` notification
   context, but this does not prove that sharing one session is operationally
   safe. Concurrent-device policy and collision tests remain a gate. Default
   proposal: one declared device/session writer until proven otherwise.
4. **External identity.** Generate one cryptographically random UUID per local
   draft and stable UUIDs for every line **and payment**. Persist them before the
   first request and never regenerate on retry. Odoo searches and constrains
   orders by UUID and constrains line/payment UUIDs; server order naming remains
   Odoo-owned.
5. **Restaurant tables.** Standard `pos_restaurant` adds `pos.order.table_id`.
   Its open-order lookup can match a draft by table/config even when the incoming
   UUID differs. Order UUID alone is therefore not sufficient isolation for
   Restaurant drafts. BotecoPRO needs a deterministic one-writer/merge policy
   and collision tests before synchronizing a table.
6. **Taxes.** Odoo computes totals from order-line inputs with `account.tax` and
   fiscal-position data. Server recomputation does not prove that a client chose
   the correct taxes or fiscal position. Flutter must not implement an
   independent tax engine; the exact line payload and selection must match a
   supported standard POS path.
7. **Pricelist.** The POS/customer/order context can alter `price_unit`;
   `lst_price` used by M7 is informational only. Reading a currency or pricelist
   ID is not a pricing engine. A supported Odoo pricing method or the exact
   standard frontend contract must be validated before submission.
8. **Payments.** Payments are part of the same order payload and must use payment
   methods available to the session. Odoo recomputes `amount_paid`; BotecoPRO
   must never trust its local subtotal as the final payable amount.
9. **Stock.** For a non-draft saved order, Odoo marks it paid and calls
   `_create_order_picking`; configuration can defer some stock processing to
   session closing. This is an inventory side effect requiring a test database.
10. **Accounting.** An invoiced paid order can generate its invoice immediately.
    Session closing creates/posts the session journal entry and reconciliations;
    some payment methods can create accounting payments. Closing and invoicing
    remain outside BotecoPRO's first write milestone.
11. **Timeouts.** A timeout is an unknown result, never a confirmed failure.
    Read by the persisted order UUID before deciding to retry. The upstream
    `read_pos_data_uuid` method is a candidate only if the target `/doc` exposes
    it; otherwise use an authorized explicit read domain.
12. **Duplicate prevention.** Stable order, line and payment UUIDs are the
    candidate idempotency identities. Restaurant table matching is an additional
    collision path, so UUID constraints alone do not prove end-to-end safety.
    Never generate new identities on retry.
13. **Reconciliation.** After timeout, read by UUID in the same company/POS. If
    found, compare returned state/lines. If absent, retry the identical payload.
14. **Safe retry set.** Read-by-UUID is always first. Repeating an identical
    `sync_from_ui` call is only a candidate after paid-order behavior is proven.
    Payment terminal/provider calls are never assumed retry-safe.
15. **Method choice.** `sync_from_ui`, not direct ORM creates, is the current
    standard-first provisional candidate. It remains unapproved until JSON-2
    dynamic documentation, ACLs, payload fixtures, pricing and side effects pass
    in isolation.

## Read-only proof required before any rehearsal

- verify `sync_from_ui` and an order read-back method in the authenticated
  dynamic `/doc`, without invoking either write path;
- read the selected `pos.config`, open `pos.session` records and their owners;
- read the POS currency, default/available pricelists and payment methods;
- record whether payment methods use split transactions or external terminals;
- inspect the relevant fiscal-position/tax metadata without deriving a custom
  Flutter tax result;
- verify model access and record visibility for the API-key user;
- keep exact record IDs, company names and operational values in local ignored
  evidence rather than public documentation.

## Required proof before implementation

- reconcile the company's fiscal identity and historical document ownership;
- open a test POS session through the standard Odoo workflow;
- capture a sanitized standard POS payload fixture from the same SaaS version;
- validate M8a as a draft-only operational rehearsal in a disposable database;
- validate M8b separately only after pricing, tax and payment gates pass;
- prove UUID retry and uncertain-result reconciliation;
- prove same-table collision/merge behavior;
- assert stock, payment, tax, invoice and session-closing effects;
- decide explicitly how devices own/share sessions.

Until these gates pass, the supported boundary remains:

```text
Odoo read → Flutter operational UI → versioned snapshot + local draft cart
```
