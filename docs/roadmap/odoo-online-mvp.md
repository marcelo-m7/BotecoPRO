# Odoo Online MVP roadmap

1. **M0** — branches, submodule baseline, legacy secret cleanup and CI.
2. **M1** — injectable JSON-2 transport and safe error mapping.
3. **M2** — connection form, metadata store and secure API-key store.
4. **M3** — version/authentication/identity/company/POS diagnostics.
5. **M4** — company selection and restricted multi-company context.
6. **M5** — POS configuration selection.
7. **M6** — paginated POS categories and products, search/filter/detail and a
   client-side non-fiscal cart with optional read-only Restaurant table context.
8. **M7** — implemented and covered automatically: versioned read snapshots,
   explicit offline/stale state, persistent context-bound draft cart and
   product reconciliation. The full device/network interruption rehearsal
   remains a release acceptance check.
9. **M8** — controlled POS writes after validating session, payments, stock,
   taxes and accounting effects. Local stable UUID allocation and fail-closed
   preflight are implemented; no mutating transport exists yet.
10. **Future** — outbox, retries, conflicts, device provisioning and QR/deep
    link credential onboarding.

M0–M7 are the current implementation boundary. Smoke tests against the configured
Odoo Online instance are local-only and read-only. A POS must return a nonzero
catalog through its configured categories before the MVP is accepted.

## Current data gate

The configured company's fiscal identity and the ownership of historical
supplier documents require documentary reconciliation. Those documents are not
accounting evidence for the selected Odoo company until that review is
completed. Detailed company, supplier and accounting-record evidence remains
local and is not published in this repository. This blocks M8 writes but not
the read-only connection, identity, POS and product milestones.

## Next write boundary

The next milestone may rehearse a controlled `pos.order` flow only after the ADR
validates the target dynamic contract, native POS session ownership,
pricelist/tax computation, payment, stock and accounting effects in a disposable
database. The current cart remains local and is never an outbox or a queued
Odoo write. Its persisted UUIDs are retry identities reserved for that future
rehearsal, not evidence of Odoo synchronization.
See `docs/architecture/adr-m8-controlled-pos-write.md` for the unresolved gates.
