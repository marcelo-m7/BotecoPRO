# GitHub Copilot Instructions – BotecoPRO

You are assisting with **BotecoPRO**, a bar/restaurant management platform built on:
- **Odoo 17/19** (ERP backend, POS, accounting)
- **Flutter** (mobile/POS client)
- **Website** (public-facing, strategy under evaluation)

---

## Context

This is a monorepo. The source of truth is this repository.
Previous code lived in `marcelo-m7/BotecoPro-app` and `marcelo-m7/BotecoPRO-website` – their histories were imported via `git subtree`.

---

## Non-negotiable rules

1. **Odoo Standard First** – check Odoo's standard models before creating new ones.
2. **No core Odoo edits** – customisations live only in `addons/botecopro_*`.
3. **No secrets** – never suggest code that contains passwords, tokens, or API keys.
4. **Conventional Commits** – always use proper commit prefix + scope.
5. **Update docs** – when suggesting API or architecture changes, also update `docs/`.
6. **Offline-first** – Flutter features must support offline operation via local cache + outbox queue.

---

## Key files to read before making changes

- `AGENTS.md` – full guidelines
- `docs/architecture/domain-mapping.md` – Odoo model mapping
- `docs/architecture/offline-sync.md` – sync strategy
- `docs/api/README.md` – API contracts
- `apps/mobile/README.md` – Flutter architecture
- `addons/botecopro_api/README.md` – API addon

---

## Preferred patterns

### Odoo addon

```python
# models/botecopro_venue.py
from odoo import models, fields

class BotecoproVenue(models.Model):
    _name = 'botecopro.venue'
    _description = 'BotecoPRO Venue'
    _inherits = {}  # extend standard when possible

    company_id = fields.Many2one('res.company', required=True, ondelete='restrict')
```

### Flutter API call

```dart
// Always go through the repository layer
final orders = await _orderRepository.getOrders(since: lastSync);
```

### API endpoint (botecopro_api)

```python
@http.route('/api/v1/botecopro/health', auth='none', type='json', methods=['GET'])
def health(self, **kwargs):
    return {'status': 'ok', 'version': '1'}
```
