# BotecoPRO – Agent Guidelines

This file defines rules and context for AI coding agents (GitHub Copilot, Claude, GPT, etc.)
working in this repository.

---

## Golden Rules

1. **Study before changing** – Read relevant source files and docs before modifying anything.
2. **Odoo Standard First** – Check whether Odoo already provides the functionality. Do not recreate what Odoo offers.
3. **Never duplicate standard models** – Extend `res.partner`, `pos.order`, `sale.order`, etc. instead of reimplementing them.
4. **Never edit Odoo core** – All customisations live under `addons/`.
5. **Small, traceable commits** – Follow [Conventional Commits](https://www.conventionalcommits.org/). One logical change per commit.
6. **No secrets in the repository** – Never commit `.env`, API keys, passwords, or tokens. Use `.env.example` with placeholder values.
7. **No undocumented dependencies** – Every new dependency must be justified in the PR description.
8. **Tests before concluding** – Run `make test` (or sub-targets) after changes. CI must pass.
9. **Update docs with code** – Architecture changes require updating `docs/architecture/`. API changes require updating `docs/api/`.
10. **Preserve offline capability** – The Flutter app must continue to function with limited connectivity. See `docs/architecture/offline-sync.md`.

---

## Project Architecture Overview

```
BotecoPRO/
├── addons/               ← Odoo custom addons (Python)
│   ├── botecopro_core/   ← Domain models & extensions of Odoo standard
│   ├── botecopro_api/    ← REST API layer for mobile/website integration
│   └── botecopro_website/← Odoo Website extensions / portal pages
│
├── apps/
│   ├── mobile/           ← Flutter app (iOS, Android, POS terminal)
│   └── website/          ← Public-facing website (may migrate to Odoo Website)
│
├── packages/
│   ├── api_contracts/    ← Shared API request/response schemas (OpenAPI / JSON)
│   └── shared/           ← Shared utilities between apps
│
├── infrastructure/
│   └── docker/           ← docker-compose for local dev
│
└── docs/                 ← Architecture, API, migration, development docs
```

---

## Domain Mapping (Odoo ↔ BotecoPRO)

See full details in `docs/architecture/domain-mapping.md`.

| BotecoPRO Concept | Odoo Model               |
|-------------------|--------------------------|
| Customer          | `res.partner`            |
| Product           | `product.template`       |
| Category          | `pos.category`           |
| Order (POS)       | `pos.order`              |
| Order (delivery)  | `sale.order`             |
| Employee          | `hr.employee`            |
| User              | `res.users`              |
| Payment           | `pos.payment`            |
| Stock             | `stock.quant`            |
| Company/venue     | `res.company`            |

---

## Addon Conventions

- Each addon has `__manifest__.py`, `__init__.py`, and standard subdirs (`models/`, `views/`, `security/`, `data/`, `static/`).
- Model names follow `botecopro.*` prefix for custom models.
- Do not add `depends` on community modules without explicit discussion.
- `botecopro_api` exposes endpoints under `/api/v1/botecopro/`.

---

## Flutter Conventions

- Architecture: feature-first with repository pattern.
- State management: BLoC (or Riverpod – see `apps/mobile/` README for current choice).
- All Odoo communication goes through the repository layer, never from UI directly.
- Local persistence via Hive or SQLite – never hardcoded data.
- Offline queue must be respected for order creation.

---

## Commit Prefixes

```
feat:     New feature
fix:      Bug fix
docs:     Documentation only
style:    Formatting, no logic change
refactor: Refactoring without behavior change
test:     Tests
chore:    Tooling, config, deps
ci:       CI/CD changes
```

Scope examples: `feat(api):`, `fix(mobile):`, `docs(architecture):`, `chore(odoo):`

---

## What NOT to do

- Do not create new Odoo models that mirror `res.partner`, `pos.order`, `product.template`, etc.
- Do not bypass the `botecopro_api` addon to call Odoo JSON-RPC directly from Flutter (unless prototyping).
- Do not add new Python dependencies to addons without updating `__manifest__.py` `external_dependencies`.
- Do not merge to `main` without a passing CI.
- Do not delete `apps/website/` – it is preserved during Fase 0 pending website strategy decision.
