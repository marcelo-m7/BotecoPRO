# Offline roadmap

The MVP is intentionally online-first:

```text
Odoo JSON-2 → repository → optional local snapshot → Flutter UI
```

No write outbox, retry queue, conflict resolver or server-side synchronizer is
implemented in the connection/products milestone. Existing local demo screens
are isolated and are not synchronized with Odoo.

Future work must preserve the following boundaries:

- API key remains in secure storage and is never copied to a database;
- snapshots are versioned and identified by Odoo IDs and `write_date`;
- reads use domains, fields and incremental pagination;
- writes use an outbox with retry classification and idempotency keys;
- POS writes are only enabled after session, payment, stock and accounting
  behavior is validated against Odoo;
- conflicts are surfaced to the operator instead of silently overwriting
  business data.
