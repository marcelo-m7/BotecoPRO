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
identidade, empresas, POS, categorias, produtos e contexto Restaurant.

O aplicativo integrado é o submódulo `apps/mobile`, apontado para a branch
`feat/odoo-online-mvp` e fixado sempre num commit já publicado no remoto do
repositório `BotecoPro-app`.

## Desenvolvimento

```bash
git clone --recurse-submodules https://github.com/marcelo-m7/BotecoPRO.git
cd BotecoPRO
cp .env.example .env.local
# preencher a API key apenas localmente

make doctor
make bootstrap
make verify
```

O Makefile delega à CLI Python canônica em `scripts/`, que fixa expectativas de
Flutter/Java/Android, executa Flutter sempre em `apps/mobile` e produz logs,
relatórios e evidências locais apenas sob diretórios ignorados. Antes de usar
dispositivo ou emulador Android, execute `make android-doctor`. Consulte
[`scripts/README.md`](scripts/README.md) para os fluxos físicos, emulador e CI.

`.env.local` é ignorado pelo Git. A API key nunca deve aparecer em código,
fixtures, logs, documentação, analytics ou CI.

O smoke test Odoo é opt-in, read-only e executado apenas localmente contra a
instância configurada pelo utilizador.

## Escopo do MVP

- conexão e diagnóstico JSON-2;
- utilizador atual e empresas permitidas;
- configurações POS autorizadas;
- categorias POS e catálogo completo paginado, em modo read-only;
- pisos/mesas Restaurant em leitura;
- snapshot local versionado e estado offline explícito;
- comanda local persistente, não fiscal e reconciliada com o catálogo.

Pedidos Odoo, pagamentos, movimentos de stock, writes contabilísticos, outbox
offline e provisionamento de dispositivos estão documentados como fases
posteriores.

## Documentação

- `docs/architecture/odoo-online-direct.md` — decisão arquitetural e contrato de transporte;
- `docs/architecture/domain-mapping.md` — mapeamento Flutter/Odoo;
- `docs/architecture/offline-sync.md` — snapshot M7 e roadmap offline futuro;
- `docs/roadmap/odoo-online-mvp.md` — milestones e critérios de aceite;
- `docs/evidence/README.md` — capturas reais, originais e escopo da evidência;
- `docs/archive/` — decisões e contratos intermediários históricos.
