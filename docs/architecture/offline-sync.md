# Offline read snapshot and future roadmap

M7 implements a deliberately small read-continuity layer:

```text
Odoo JSON-2 → complete paginated sync → versioned local snapshot → Flutter UI
```

The schema-v1 snapshot contains the selected company/POS catalog, POS
categories, readable Restaurant floors/tables, Odoo version and synchronization
time. Product pages are fetched until the expected catalog is complete; only
then is the snapshot published atomically. Restaurant reads are best-effort:
missing-model and read-permission failures result in an empty Restaurant
section without weakening catalog completeness. The snapshot is accepted only
for the exact normalized instance, authenticated user ID, company and POS. An
incompatible schema or context is discarded. API keys, headers, cookies and
authentication payloads are never serialized.

Only network failures may activate the snapshot. Authentication, authorization
and configuration failures never fall back to cache. The UI labels cached data
as offline and shows the last successful synchronization time; demo data is
never substituted.

The comanda is a separate schema-v1 local draft. It survives restart only in
the same context and retains captured informational prices. After a fresh sync,
items are classified as available, changed or unavailable without deleting
them. This draft is not an outbox and cannot create an Odoo order.

M7 deliberately stores one snapshot slot and one draft slot. A context mismatch
invalidates that slot; it does not retain or merge multiple company/POS caches.

Future work must preserve the following boundaries:

- API key remains in secure storage and is never copied to a database;
- incompatible snapshot versions are discarded instead of migrated in M7;
- reads use explicit domains and fields plus bounded server pagination to
  assemble one complete snapshot;
- writes use an outbox with retry classification and idempotency keys;
- POS writes are only enabled after session, payment, stock and accounting
  behavior is validated against Odoo;
- conflicts are surfaced to the operator instead of silently overwriting
  business data.
