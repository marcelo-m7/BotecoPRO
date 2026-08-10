# BotecoPRO

Monorepo de produto para gestão de bares, com o aplicativo Flutter em
`apps/mobile` e o website em `apps/website`.

## Arquitetura atual

```text
BotecoPRO Flutter nativo
          ↓ HTTPS + Bearer API key
Odoo JSON-2
          ↓
Odoo Online (saas~19.4+e)
```

O MVP não possui backend BotecoPRO, REST API própria, Supabase, FastAPI,
middleware ou addons Python obrigatórios. Odoo é a fonte de verdade de
identidade, empresas, POS, categorias e produtos.

O aplicativo integrado é o submódulo `apps/mobile`, apontado para a branch
`feat/odoo-online-mvp` e fixado sempre num commit já publicado no remoto do
repositório `BotecoPro-app`.

## Desenvolvimento

```bash
git clone --recurse-submodules https://github.com/marcelo-m7/BotecoPRO.git
cd BotecoPRO
cp .env.example .env.local
# preencher a API key apenas localmente

cd apps/mobile
flutter pub get
flutter analyze
flutter test
```

`.env.local` é ignorado pelo Git. A API key nunca deve aparecer em código,
fixtures, logs, documentação, analytics ou CI.

O smoke test Odoo é opt-in, read-only e executado apenas localmente contra a
instância configurada pelo utilizador.

## Escopo do MVP

- conexão e diagnóstico JSON-2;
- utilizador atual e empresas permitidas;
- configurações POS autorizadas;
- categorias POS e produtos paginados, em modo read-only.

Mesas, pedidos, pagamentos, stock writes, offline avançado e provisionamento
de dispositivos estão documentados como fases posteriores.

## Documentação

- `docs/architecture/odoo-online-direct.md` — decisão arquitetural e contrato de transporte;
- `docs/architecture/domain-mapping.md` — mapeamento Flutter/Odoo;
- `docs/architecture/offline-sync.md` — roadmap offline futuro;
- `docs/roadmap/odoo-online-mvp.md` — milestones e critérios de aceite;
- `docs/archive/` — decisões e contratos intermediários históricos.
