# Odoo Online MVP roadmap

1. **M0** — branches, submodule baseline, legacy secret cleanup and CI.
2. **M1** — injectable JSON-2 transport and safe error mapping.
3. **M2** — connection form, metadata store and secure API-key store.
4. **M3** — version/authentication/identity/company/POS diagnostics.
5. **M4** — company selection and restricted multi-company context.
6. **M5** — POS configuration selection.
7. **M6** — paginated POS categories and products, search/filter/detail and a
   client-side non-fiscal cart with optional read-only Restaurant table context.
8. **M7** — versioned local snapshots and stale-data indicators.
9. **M8** — controlled POS writes after validating session, payments, stock,
   taxes and accounting effects.
10. **Future** — outbox, retries, conflicts, device provisioning and QR/deep
    link credential onboarding.

M0–M6 are the first acceptance boundary. Smoke tests against the configured
Odoo Online instance are local-only and read-only. A POS must return a nonzero
catalog through its configured categories before the MVP is accepted.

## Current data gate

The Bar do Jonas fiscal identity and the recipient of historical AmBev NF-e
documents require documentary reconciliation. The related `account.move`
records remain drafts and are not accounting evidence for the configured Odoo
company until that review is completed. This blocks M8 writes but not the
read-only connection, identity, POS and product milestones.

## Next write boundary

The next milestone may design a controlled `pos.order` flow only after an ADR
validates native POS session ownership, pricelist/tax computation, payment,
stock and accounting effects. The current cart remains local and is never an
outbox or a queued Odoo write.
