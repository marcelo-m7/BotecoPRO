# ADR M8: controlled Odoo POS order write (research only)

Status: **proposed and blocked**. This ADR does not authorize writes.

## Context and evidence

Odoo 19 JSON-2 exposes public model methods and commits each call in its own SQL
transaction. Odoo explicitly recommends one business method for related writes,
especially reservations and payments. Therefore direct sequences of
`pos.order.create`, `pos.order.line.create` and `pos.payment.create` are rejected.

The Odoo 19 standard source defines `pos.order.sync_from_ui(orders)`. It resolves
an existing order by `uuid`, updates only draft orders and processes each order
through the same server workflow used by the standard POS UI. The model and its
lines have unique UUID constraints. These properties make `sync_from_ui` the
only current candidate; a write spike must still validate the exact SaaS 19.4
payload shown by the authenticated `/doc` page and the standard frontend.

Sources:

- [Odoo 19 JSON-2 API and transaction boundary](https://www.odoo.com/documentation/19.0/developer/reference/external_api.html)
- [Odoo 19 standard `pos.order` implementation](https://github.com/odoo/odoo/blob/19.0/addons/point_of_sale/models/pos_order.py)
- [Odoo 19 Restaurant order extension](https://github.com/odoo/odoo/blob/19.0/addons/pos_restaurant/models/pos_order.py)
- [Odoo 19 POS session implementation](https://github.com/odoo/odoo/blob/19.0/addons/point_of_sale/models/pos_session.py)
- [Odoo 19 POS pricing](https://www.odoo.com/documentation/19.0/applications/sales/point_of_sale/extra/pricing.html)
- [Odoo 19 Restaurant workflow](https://www.odoo.com/documentation/19.0/applications/sales/point_of_sale/restaurant.html)

## Decisions and open gates

1. **Session requirement.** A payload references `session_id`. If that session is
   closing or closed, Odoo searches an opened session for the same POS and fails
   when none exists. M8 requires an explicitly opened standard `pos.session`;
   BotecoPRO will not open one implicitly.
2. **Session ownership.** `pos.session.user_id` identifies the Odoo user who
   opened it. The authenticated BotecoPRO user must be authorized for that POS,
   and the UI must show the session owner before submission.
3. **Multiple devices.** The source carries a `device_identifier` notification
   context, but this does not prove that sharing one session is operationally
   safe. Concurrent-device policy and collision tests remain a gate. Default
   proposal: one declared device/session writer until proven otherwise.
4. **External identity.** Generate one cryptographically random UUID per local
   draft and stable UUIDs for every line. Persist them before the first request
   and never regenerate on retry. Odoo searches and constrains orders by UUID;
   server order naming remains Odoo-owned.
5. **Restaurant tables.** Standard `pos_restaurant` adds `pos.order.table_id`.
   Draft restaurant orders can also be resolved by table/config, so BotecoPRO
   must avoid two unrelated drafts for the same table and POS.
6. **Taxes.** Odoo computes totals with `account.tax` and fiscal-position data.
   Flutter must not implement an independent tax engine. The exact line payload
   and fiscal-position selection must match the standard POS frontend.
7. **Pricelist.** The POS/customer pricelist can alter `price_unit`; `lst_price`
   used by M7 is informational only. A supported Odoo pricing path or exact
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
    Query `pos.order` by the persisted UUID before deciding to retry.
12. **Duplicate prevention.** The stable order UUID is the idempotency key;
    stable line UUIDs prevent duplicate lines. Never generate a new UUID on retry.
13. **Reconciliation.** After timeout, read by UUID in the same company/POS. If
    found, compare returned state/lines. If absent, retry the identical payload.
14. **Safe retry set.** Read-by-UUID is always first. Repeating an identical
    `sync_from_ui` call is only a candidate after paid-order behavior is proven.
    Payment terminal/provider calls are never assumed retry-safe.
15. **Method choice.** `sync_from_ui`, not direct ORM creates, is the standard-
    first candidate. It remains unapproved until JSON-2 dynamic documentation,
    ACLs, payload fixtures, pricing and side effects pass in isolation.

## Required proof before implementation

- reconcile the company's fiscal identity and historical document ownership;
- open a test POS session through the standard Odoo workflow;
- capture a sanitized standard POS payload fixture from the same SaaS version;
- validate a non-fiscal rehearsal in a disposable database;
- prove UUID retry and uncertain-result reconciliation;
- assert stock, payment, tax, invoice and session-closing effects;
- decide explicitly how devices own/share sessions.

Until these gates pass, the supported boundary remains:

```text
Odoo read → Flutter operational UI → versioned snapshot + local draft cart
```
