# BotecoPRO – Estratégia Offline-First

> Fase 0 – Fundação Arquitetural

---

## 1. Visão Geral

O aplicativo Flutter deve funcionar com conectividade limitada ou ausente. Esta é uma exigência operacional real para bares e restaurantes onde a rede Wi-Fi pode ser instável durante o pico de serviço.

---

## 2. Fluxo de Dados

### Leitura (Odoo → App)

```
Odoo (fonte de verdade)
   ↓  HTTPS/JSON
BotecoPRO API  (/api/v1/botecopro/*)
   ↓
Flutter Repository Layer  (lib/core/repositories/)
   ↓
Local Database / Cache  (SQLite via sqlite3)
   ↓
BLoC / Provider
   ↓
UI
```

### Escrita / Sincronização (App → Odoo)

```
UI (user action)
   ↓
BLoC / Provider
   ↓
Flutter Repository Layer
   ↓  online?  ──→  BotecoPRO API  ──→  Odoo
   ↓  offline
Outbox (SQLite table: pending_operations)
   ↓
SyncService (background Isolate ou WorkManager)
   ↓  when connectivity restored
BotecoPRO API
   ↓
Odoo
```

---

## 3. Camadas Flutter

### 3.1 Cache Local (SQLite)

Tabelas mínimas necessárias:

```sql
-- Entidades sincronizadas do Odoo
CREATE TABLE products (
    id          INTEGER PRIMARY KEY,       -- Odoo ID
    client_ref  TEXT UNIQUE,               -- UUID Flutter (pode preceder sync)
    data        TEXT NOT NULL,             -- JSON snapshot
    write_date  TEXT NOT NULL,             -- Odoo write_date (ISO 8601)
    synced_at   TEXT NOT NULL              -- timestamp da última sync
);

CREATE TABLE customers (
    id          INTEGER,
    client_ref  TEXT UNIQUE NOT NULL,
    data        TEXT NOT NULL,
    write_date  TEXT,
    synced_at   TEXT
);

CREATE TABLE orders (
    id          INTEGER,                   -- NULL se criado offline
    client_ref  TEXT UNIQUE NOT NULL,      -- UUID sempre presente
    data        TEXT NOT NULL,
    write_date  TEXT,
    synced_at   TEXT,
    status      TEXT NOT NULL DEFAULT 'local'  -- local | synced | error
);

-- Fila de operações pendentes (outbox)
CREATE TABLE pending_operations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    client_ref  TEXT NOT NULL,             -- UUID da entidade
    entity_type TEXT NOT NULL,             -- 'order' | 'customer' | 'payment'
    operation   TEXT NOT NULL,             -- 'create' | 'update' | 'delete'
    payload     TEXT NOT NULL,             -- JSON do payload para a API
    created_at  TEXT NOT NULL,
    attempts    INTEGER NOT NULL DEFAULT 0,
    last_error  TEXT
);
```

---

### 3.2 IDs e Rastreabilidade

**Problema:** Odoo usa IDs inteiros atribuídos pelo servidor. O Flutter precisa criar entidades offline antes de receber o ID Odoo.

**Solução:**

- O Flutter gera um **UUID v4** (`client_ref`) para cada entidade no momento da criação.
- O UUID é enviado para o Odoo via API e armazenado em `botecopro_client_ref` / `botecopro_customer_ref`.
- Após sync bem-sucedida, o Flutter armazena o `odoo_id` inteiro localmente.
- Referências internas locais usam `client_ref`; referências para Odoo usam `odoo_id`.

```dart
// Exemplo de criação de pedido offline
final order = Order(
  clientRef: const Uuid().v4(),   // gerado localmente
  odooId: null,                   // preenchido após sync
  tableClientRef: table.clientRef,
  ...
);
await _localDb.saveOrder(order);
await _outbox.enqueue(OrderCreateOperation(order));
```

---

### 3.3 Sincronização Incremental (`write_date`)

O Odoo mantém `write_date` em todos os modelos. A sync incremental usa este campo:

```
GET /api/v1/botecopro/products?since=2024-01-15T10:00:00Z
```

O cliente envia o timestamp da última sync e recebe apenas os registros alterados.

**Algoritmo de sync:**

1. Ler `last_sync_at` do storage local (por tipo de entidade).
2. Chamar `GET /api/v1/botecopro/{entity}?since={last_sync_at}`.
3. Para cada registro recebido:
   - Se `client_ref` presente → `INSERT OR REPLACE` no cache.
   - Se `odoo_id` não conhecido localmente → novo registro.
4. Atualizar `last_sync_at`.
5. Processar outbox de operações pendentes.

---

### 3.4 Outbox e Retries

```dart
class SyncService {
  // Intervalo de retry com backoff exponencial
  static const retryIntervals = [30, 60, 120, 300, 600]; // segundos

  Future<void> processOutbox() async {
    final pending = await _localDb.getPendingOperations();
    for (final op in pending) {
      try {
        await _api.execute(op);
        await _localDb.markSynced(op.id);
      } on ApiException catch (e) {
        if (e.isRetryable) {
          await _localDb.incrementAttempts(op.id, e.message);
        } else {
          await _localDb.markFailed(op.id, e.message);
          // Notificar utilizador sobre operação não sincronizável
        }
      }
    }
  }
}
```

**Erros retentáveis:** timeout, 5xx, sem rede.  
**Erros não retentáveis:** 4xx (dados inválidos), conflitos irrecuperáveis.

---

### 3.5 Idempotência

Todas as operações de criação enviadas ao Odoo **devem incluir o `client_ref`**:

```json
POST /api/v1/botecopro/orders
{
  "client_ref": "uuid-4-do-flutter",
  "table_client_ref": "uuid-da-mesa",
  "lines": [...]
}
```

O Odoo verifica se já existe um `pos.order` com aquele `botecopro_client_ref` e retorna o existente em vez de criar duplicado.

---

### 3.6 Resolução de Conflitos

Dado que o POS opera em ambiente controlado (um caixa por vez por mesa), conflitos reais são raros. Estratégia inicial:

| Cenário | Estratégia |
|---|---|
| Dois dispositivos editam o mesmo pedido | **Last-write-wins** com base em `write_date` |
| Pedido criado offline e mesa foi fechada por outro caixa | API retorna erro 409 → notificar utilizador, pedido permanece como "erro" no outbox |
| Stock insuficiente detectado na sync | Notificação local; item marcado como `stock_error`; sem rollback automático |
| Auth expirada durante operação offline | Operação armazenada no outbox; ao reconectar, pedir re-autenticação antes de processar |

---

## 4. Pedidos Criados Offline

Fluxo completo:

```
1. Waiter cria pedido no Flutter (sem rede)
   → Order com client_ref, status='local'
   → Enqueue(OrderCreateOperation)

2. App continua funcionando normalmente
   → Baixa de stock local otimista (subtrair qty_on_hand local)

3. Rede restaurada → SyncService.processOutbox()
   → POST /api/v1/botecopro/orders { client_ref: ... }
   → Odoo verifica client_ref → cria pos.order → retorna odoo_id

4. Flutter atualiza cache:
   → order.odoo_id = id retornado
   → order.status = 'synced'

5. Sync incremental → buscar write_date dos últimos pedidos
   → Atualizar stock real do Odoo no cache local
```

---

## 5. Autenticação Expirada Offline

- Sessão Odoo tem TTL configurável (padrão: 1 semana com atividade).
- O Flutter armazena o `session_id` encriptado localmente.
- Se a sessão expirar enquanto offline:
  - Operações de leitura continuam funcionando com cache local.
  - Operações de escrita são enfileiradas no outbox.
  - Ao reconectar, `SyncService` detecta 401 → exibe tela de re-login → após login, retoma o outbox.
- **Fase 1:** Implementar refresh token ou JWT de curta duração para minimizar re-logins.

---

## 6. Versionamento da API

- Todas as rotas incluem versão: `/api/v1/botecopro/`.
- O Flutter envia header `X-BotecoPRO-Version: {app_version}`.
- A API retorna o campo `api_version` no endpoint `/health`.
- Versões antigas são mantidas com deprecation notice por no mínimo 2 versões do app.
- **Estratégia de migração:** endpoint `/bootstrap` retorna a versão mínima suportada; se o app estiver abaixo, força atualização.

---

## 7. Considerações de Segurança

- Nunca armazenar passwords no SQLite local.
- `session_id` armazenado em `flutter_secure_storage` (keychain / keystore).
- Dados do cache local não são encriptados por padrão em Fase 0; avaliar encriptação em Fase 1 se dados sensíveis forem cacheados.
- Comunicação sempre HTTPS em produção.

---

## 8. Estado de Implementação

| Componente | Status | Fase |
|---|---|---|
| SQLite cache local (`sqlite3` pkg) | ✅ Implementado (DatabaseProvider) – não wired | Fase 1 |
| UUID generation | ✅ Presente (`uuid` pkg) | Fase 1 |
| `write_date` fields | Estrutura presente no DatabaseProvider | Fase 1 |
| Outbox / pending_operations | ❌ Não implementado | Fase 1 |
| SyncService | ❌ Não implementado | Fase 1 |
| API client (http pkg) | ❌ Pkg declarado, não usado | Fase 1 |
| Connectivity detection | ❌ Não implementado | Fase 1 |
| Auth refresh | ❌ Não implementado | Fase 1 |
