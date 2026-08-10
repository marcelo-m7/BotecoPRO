# BotecoPRO API – Documentação

> Versão: 1 (v1) | Addon: `botecopro_api` | Base URL: `/api/v1/botecopro`

---

## 1. Visão Geral

A BotecoPRO API é uma camada HTTP REST construída sobre Odoo, exposta pelo addon `botecopro_api`.

Ela abstrai os detalhes internos do Odoo e fornece endpoints optimizados para o aplicativo Flutter e integrações externas.

**O aplicativo Flutter NÃO deve chamar o JSON-RPC nativo do Odoo diretamente** (exceto durante prototipos). Toda comunicação deve passar pela BotecoPRO API.

---

## 2. Autenticação

### Fase 0 / 1: Session-based

```
POST /api/v1/botecopro/auth/login
Content-Type: application/json

{
  "login": "user@example.com",
  "password": "secret"
}

→ 200 OK
{
  "ok": true,
  "data": {
    "uid": 3,
    "name": "João Silva",
    "login": "joao@boteco.pt",
    "session_id": "abc123..."
  }
}
```

O `session_id` é enviado como cookie `session_id` em requests subsequentes, ou via header `X-Openerp-Session-Id`.

### Fase 2+: JWT (planejado)

- Access token de curta duração (15 min)
- Refresh token de longa duração (7 dias)
- Endpoint: `POST /api/v1/botecopro/auth/refresh`

---

## 3. Formato de Respostas

### Sucesso

```json
{
  "ok": true,
  "data": { ... }
}
```

### Lista com paginação

```json
{
  "ok": true,
  "data": {
    "items": [...],
    "total": 42,
    "offset": 0,
    "limit": 20
  }
}
```

### Erro

```json
{
  "ok": false,
  "error": "Mensagem de erro human-readable"
}
```

---

## 4. Headers

| Header | Obrigatório | Descrição |
|---|---|---|
| `Content-Type: application/json` | Sim (POST/PUT) | Formato do body |
| `X-BotecoPRO-Version: 1.0.0` | Recomendado | Versão do app Flutter |
| `Cookie: session_id=...` | Sim (auth) | Sessão Odoo |

---

## 5. Parâmetros de Sincronização

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `since` | ISO 8601 | Retorna apenas registros com `write_date > since` |
| `limit` | int | Máximo de registros (padrão: 100) |
| `offset` | int | Paginação offset |

---

## 6. Endpoints

### Implementados (Fase 0)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/health` | none | Health check + versão |
| `POST` | `/auth/login` | none | Login |
| `POST` | `/auth/logout` | user | Logout |

### Planejados (Fase 1)

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| `GET` | `/bootstrap` | user | Dados iniciais (produtos, categorias, mesas, config) |
| `GET` | `/products` | user | Catálogo de produtos (`?since=`, `?limit=`, `?offset=`) |
| `GET` | `/categories` | user | Categorias POS |
| `GET` | `/customers` | user | Lista de clientes |
| `POST` | `/customers` | user | Criar/atualizar cliente (upsert por `client_ref`) |
| `GET` | `/orders` | user | Pedidos (`?since=`, `?table_id=`, `?status=`) |
| `POST` | `/orders` | user | Criar pedido (com `client_ref` para idempotência) |
| `PUT` | `/orders/{id}` | user | Atualizar pedido |
| `POST` | `/orders/{id}/pay` | user | Registrar pagamento |
| `POST` | `/sync` | user | Envio de operações pendentes em batch |

---

## 7. Exemplos de Payloads

### `GET /health`

```json
{
  "ok": true,
  "data": {
    "status": "ok",
    "api_version": "1",
    "botecopro_version": "0.1.0"
  }
}
```

### `POST /orders` (Fase 1)

```json
{
  "client_ref": "550e8400-e29b-41d4-a716-446655440000",
  "table_client_ref": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  "employee_id": 5,
  "lines": [
    {
      "product_id": 12,
      "qty": 2,
      "price_unit": 15.50,
      "note": "sem gelo"
    }
  ]
}
```

### `POST /sync` (Fase 1)

```json
{
  "operations": [
    {
      "id": "local-op-id",
      "entity_type": "order",
      "operation": "create",
      "client_ref": "550e8400...",
      "payload": { ... }
    }
  ]
}
```

---

## 8. Contratos OpenAPI

Os schemas formais estão em:

```
packages/api_contracts/
├── openapi.yaml          ← especificação OpenAPI 3.1
└── schemas/
    ├── health.yaml
    ├── auth.yaml
    ├── orders.yaml
    ├── products.yaml
    └── customers.yaml
```

---

## 9. Erros Comuns

| Código | Causa | Solução |
|---|---|---|
| 400 | Payload inválido ou campo obrigatório ausente | Verificar schema em `packages/api_contracts/` |
| 401 | Sessão expirada ou inválida | Re-autenticar via `/auth/login` |
| 409 | `client_ref` já existe (operação duplicada) | Ignorar — a operação foi processada anteriormente |
| 422 | Validação de negócio falhou (ex: stock insuficiente) | Notificar utilizador |
| 500 | Erro interno do servidor | Consultar logs Odoo; retentável |

---

## 10. Versionamento

- URL versioning: `/api/v1/`, `/api/v2/`, ...
- Uma nova versão só é criada para breaking changes.
- Versões antigas são mantidas por no mínimo 6 meses após deprecação.
- Endpoint `/health` sempre retorna a versão mais recente.
