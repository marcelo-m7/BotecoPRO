# BotecoPRO

Plataforma de gestão para bares, restaurantes e estabelecimentos de restauração.

Construída sobre **Odoo**, **Flutter** e integrações próprias BotecoPRO.

---

## Arquitetura

```
BotecoPRO/
├── addons/                  ← Odoo custom addons (Python)
│   ├── botecopro_core/      ← Extensões de modelos standard (venue, partner, etc.)
│   ├── botecopro_api/       ← REST API para Flutter e integrações externas
│   └── botecopro_website/   ← Extensões Odoo Website (Fase 1+)
│
├── apps/
│   ├── mobile/              ← Flutter app (iOS, Android, POS terminal)
│   └── website/             ← Website público (React SPA – boteco.pt)
│
├── packages/
│   ├── api_contracts/       ← Schemas OpenAPI e contratos compartilhados
│   └── shared/              ← Utilitários partilhados
│
├── infrastructure/
│   └── docker/              ← docker-compose para ambiente local
│
└── docs/
    ├── architecture/        ← Decisões arquiteturais e mapeamento de domínio
    ├── api/                 ← Documentação da API
    ├── migration/           ← Histórico de migração dos repositórios
    └── development/         ← Guias de desenvolvimento
```

**Stack:**

| Camada | Tecnologia |
|---|---|
| Backend / ERP | Odoo 17+ (target: 19) |
| Mobile / POS | Flutter (Dart) |
| Website Público | React 18 + TypeScript + Vite |
| API | REST JSON sobre Odoo (addon `botecopro_api`) |
| Infra local | Docker Compose + PostgreSQL |

---

## Requisitos

| Ferramenta | Versão mínima |
|---|---|
| Docker + Docker Compose | 24+ |
| Flutter SDK | 3.x |
| Python | 3.11+ |
| Node.js | 20+ |
| Make | qualquer |

---

## Instalação Rápida

```bash
# 1. Clonar o repositório
git clone https://github.com/marcelo-m7/BotecoPRO.git
cd BotecoPRO

# 2. Copiar e configurar variáveis de ambiente
cp .env.example .env
# Editar .env: definir passwords do PostgreSQL e Odoo

# 3. Iniciar Odoo + PostgreSQL
make setup
make up

# Odoo estará disponível em http://localhost:8069
```

---

## Desenvolvimento

### Odoo

```bash
make up           # Iniciar serviços
make logs         # Ver logs
make down         # Parar serviços
make shell-odoo   # Shell no container Odoo
make odoo-lint    # Lint dos addons Python
make odoo-test    # Testes dos addons (requer Odoo a correr)
```

Os addons são montados automaticamente de `./addons/` no container Odoo.
Ao alterar um addon, acesse `Settings > Activate developer mode > Update Apps List`.

### Flutter

```bash
make flutter-get      # flutter pub get
make flutter-run      # flutter run
make flutter-analyze  # flutter analyze
make flutter-test     # flutter test
```

Ou diretamente:

```bash
cd apps/mobile
flutter pub get
flutter run
```

**Configuração do ambiente Flutter:**
Copie `apps/mobile/.env.example` (quando criado) e configure `FLUTTER_API_BASE_URL`:
- Android Emulator: `http://10.0.2.2:8069`
- iOS Simulator: `http://localhost:8069`

### Website

```bash
make website-dev    # servidor de desenvolvimento
make website-build  # build de produção
```

Ou:

```bash
cd apps/website
npm install
npm run dev
```

---

## Estrutura dos Addons Odoo

```
addons/
├── botecopro_core/       ← Modelos de domínio e extensões standard
│   ├── models/
│   │   ├── botecopro_venue.py   # Estabelecimento físico
│   │   └── res_partner.py       # Extensão res.partner (cliente BotecoPRO)
│   ├── views/
│   ├── security/
│   └── data/
│
├── botecopro_api/        ← REST API
│   ├── controllers/
│   │   ├── health.py    # GET /api/v1/botecopro/health
│   │   └── auth.py      # POST /api/v1/botecopro/auth/login
│   └── models/
│
└── botecopro_website/    ← Extensões Odoo Website (placeholder Fase 0)
```

---

## Estratégia de Branches

| Branch | Propósito |
|---|---|
| `main` | Produção estável |
| `develop` | Integração contínua |
| `feat/*` | Funcionalidades novas |
| `fix/*` | Correções |
| `docs/*` | Documentação |
| `chore/*` | Tooling, CI, dependências |

Commits seguem [Conventional Commits](https://www.conventionalcommits.org/).

---

## Documentação

| Documento | Conteúdo |
|---|---|
| [`docs/architecture/domain-mapping.md`](docs/architecture/domain-mapping.md) | Mapeamento de entidades Flutter → Odoo |
| [`docs/architecture/offline-sync.md`](docs/architecture/offline-sync.md) | Estratégia offline-first e sync |
| [`docs/api/README.md`](docs/api/README.md) | Contratos e documentação da API |
| [`docs/migration/repository-migration.md`](docs/migration/repository-migration.md) | Como os históricos foram incorporados |
| [`AGENTS.md`](AGENTS.md) | Regras e contexto para agentes de IA |

---

## Fases do Projeto

| Fase | Descrição | Estado |
|---|---|---|
| **Fase 0** | Consolidação e fundação arquitetural (este repositório) | ✅ Em curso |
| **Fase 1** | Migração de domínio: Flutter conectado ao Odoo via API | 🔜 Planeado |
| **Fase 2** | Website strategy: Odoo Website vs. standalone | 🔜 Futuro |
| **Fase 3** | Produção: deploy Odoo.sh / infra própria | 🔜 Futuro |

---

## Licença

MIT — ver [LICENSE](LICENSE)
