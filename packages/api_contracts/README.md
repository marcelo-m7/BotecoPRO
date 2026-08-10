# api_contracts

Schemas e contratos da BotecoPRO API.

## Arquivo Principal

`openapi.yaml` — especificação OpenAPI 3.1 completa.

## Uso

### Validação

```bash
# Com redocly
npx @redocly/cli lint openapi.yaml

# Com swagger-cli
npx swagger-cli validate openapi.yaml
```

### Geração de código Flutter

```bash
# Com openapi-generator
openapi-generator-cli generate \
  -i openapi.yaml \
  -g dart-dio \
  -o ../../apps/mobile/lib/core/api/generated/
```

### Geração de código Python (validação Odoo)

```bash
openapi-generator-cli generate \
  -i openapi.yaml \
  -g python \
  -o /tmp/botecopro-api-client/
```

## Schemas por domínio

```
schemas/
├── health.yaml      ← em breve
├── auth.yaml        ← em breve
├── orders.yaml      ← Fase 1
├── products.yaml    ← Fase 1
└── customers.yaml   ← Fase 1
```
