# BotecoPRO – Odoo Domain Mapping

> Fase 0 – Fundação Arquitetural  
> Baseado na auditoria de `marcelo-m7/BotecoPro-app@odoo` e `marcelo-m7/BotecoPRO-website@odoo`

---

## 1. Princípios de Mapeamento

1. **Odoo Standard First** — nunca recriar o que Odoo já oferece.
2. Estender modelos standard com `_inherit` quando necessário.
3. Criar modelos próprios (`botecopro.*`) apenas para conceitos sem equivalente em Odoo.
4. Manter rastreabilidade via campos de referência entre entidades Odoo e objetos Flutter.

---

## 2. Mapeamento de Entidades

### Clientes / `res.partner`

| Campo Flutter | Campo Odoo | Notas |
|---|---|---|
| `id` (UUID) | `botecopro_customer_ref` (Char, index) | UUID gerado pelo app para identificação offline |
| `name` | `name` | direto |
| `contact` | `phone` / `email` | — |
| N/A | `customer_rank = 1` | flag standard Odoo |

**Decisão:** `res.partner` já cobre toda a necessidade. O campo `botecopro_customer_ref` adicionado via `_inherit` em `botecopro_core` preserva a rastreabilidade offline.

---

### Produtos / `product.template` + `product.product`

| Campo Flutter (`Product`) | Campo Odoo | Notas |
|---|---|---|
| `id` (UUID) | `default_code` ou campo custom | referência interna |
| `name` | `name` | — |
| `category` (enum) | `pos.category` | Flutter usa food/drink/other |
| `price` | `list_price` | preço de venda |
| `stockQuantity` | `qty_on_hand` (via `stock.quant`) | não duplicar — use Odoo inventory |
| `unit` | `uom_id` | unidade de medida |
| `supplierId` | `seller_ids → res.partner` | vínculo com fornecedor |
| `description` | `description_sale` | — |

**Decisão:** Usar `product.template` para catálogo e `product.product` para variantes. Categorias de POS via `pos.category`.

---

### Categorias / `pos.category`

| Flutter (enum `ProductCategory`) | Odoo | Notas |
|---|---|---|
| `drink` | `pos.category` "Bebidas" | seed data em `botecopro_data.xml` |
| `food` | `pos.category` "Comidas" | — |
| `other` | `pos.category` "Outros" | — |

---

### Mesas / `restaurant.table`

| Campo Flutter (`TableModel`) | Campo Odoo | Notas |
|---|---|---|
| `number` | `name` | número/nome da mesa |
| `status` (free/occupied) | derivado de `pos.order.state` | não duplicar estado |
| `capacity` | `seats` | número de lugares |
| `currentOrderId` | `current_order_id` | vínculo com `pos.order` |

**Decisão:** O módulo `pos_restaurant` do Odoo já gerencia `restaurant.table` e `restaurant.floor`. Usar diretamente.

---

### Pedidos (POS) / `pos.order` + `pos.order.line`

| Campo Flutter (`Order` / `OrderItem`) | Campo Odoo | Notas |
|---|---|---|
| `id` (UUID) | `botecopro_client_ref` (Char, index) | UUID cliente para idempotência offline |
| `tableId` | `table_id → restaurant.table` | — |
| `createdAt` | `date_order` | — |
| `status` | derivado de `state` | (draft/paid/done/cancel) |
| `items[]` | `lines → pos.order.line` | — |
| `OrderItem.productId` | `product_id → product.product` | — |
| `OrderItem.quantity` | `qty` | — |
| `OrderItem.price` | `price_unit` | — |
| `OrderItem.notes` | `note` (campo custom ou `pos.order.line` já tem) | — |
| `OrderItem.status` | campo custom `botecopro_item_status` | preparação por item não existe em standard |

**Decisão:** `pos.order` + `pos.order.line` para POS. Status por item de cozinha requer campo custom em `botecopro_core`.

---

### Pedidos (Delivery/Mesa) / `sale.order`

Para pedidos que não passam pelo POS (ex: delivery, reservas futuras):

| Flutter | Odoo |
|---|---|
| `Order` | `sale.order` |
| `OrderItem` | `sale.order.line` |

---

### Vendas / Pagamentos

| Flutter (`Sale`) | Odoo | Notas |
|---|---|---|
| `paymentMethod` (cash/credit/debit/pix) | `pos.payment.method` | seed data com métodos BR |
| `total` | `amount_total` em `pos.order` | — |

**Decisão:** `pos.payment` e `pos.payment.method` cobrem os métodos de pagamento. Adicionar método "PIX" via seed data.

---

### Fornecedores / `res.partner`

| Flutter (`Supplier`) | Odoo | Notas |
|---|---|---|
| `id` | `id` + `supplier_rank` | — |
| `name` | `name` | — |
| `contact` | `phone` / `email` | — |
| `address` | `street`, `city`, etc. | — |
| `notes` | `comment` | — |

**Decisão:** `res.partner` com `supplier_rank = 1`. Não criar modelo separado.

---

### Receitas / `mrp.bom`

| Flutter (`Recipe`) | Odoo | Notas |
|---|---|---|
| `name` | `product_tmpl_id.name` | produto produzido |
| `ingredients[]` | `bom_line_ids` | componentes da ficha técnica |
| `type` (food/drink) | `product.category` | — |
| `price` | `product.list_price` | — |
| `instructions` | campo custom ou `note` | — |

**Decisão:** `mrp.bom` (Bill of Materials) cobre Receitas. Requer módulo `mrp`.

---

### Produção Interna / `mrp.production`

| Flutter (`InternalProduction`) | Odoo | Notas |
|---|---|---|
| `name` | `name` | — |
| `quantity` | `product_qty` | — |
| `recipeId` | `bom_id` | — |
| `status` (inProgress/finalized) | `state` (draft/confirmed/done/cancel) | — |
| `ingredients[]` | `move_raw_ids` | movimentos de estoque de entrada |

**Decisão:** `mrp.production` cobre Produção Interna. Requer módulo `mrp`.

---

### Funcionários / `hr.employee`

| Conceito | Odoo | Notas |
|---|---|---|
| Funcionário do estabelecimento | `hr.employee` | padrão |
| Acesso ao sistema | `res.users` | um user por funcionário com acesso |
| Função/cargo | `hr.job` | — |
| Turno | `resource.calendar` | — |

---

### Estabelecimento / `res.company` + `botecopro.venue`

| Conceito | Odoo | Notas |
|---|---|---|
| Empresa jurídica | `res.company` | um por CNPJ |
| Estabelecimento físico | `botecopro.venue` | model custom — mapeia configuração multi-caixa/multi-sala |
| Configuração POS | `pos.config` | um por caixa |
| Andar/área | `restaurant.floor` | — |

---

## 3. Módulos Odoo Necessários

| Módulo Odoo | Funcionalidade BotecoPRO |
|---|---|
| `point_of_sale` | POS, pedidos, pagamentos |
| `pos_restaurant` | Mesas, andar, comandas |
| `sale` | Pedidos delivery/reserva |
| `stock` | Inventário, baixa de estoque |
| `mrp` | Receitas, produção interna |
| `hr` | Funcionários |
| `account` | Financeiro / caixa |
| `website` | Website público (se migrado para Odoo) |
| `website_blog` | Blog (se migrado) |

---

## 4. Estratégia Website: Odoo vs. Frontend Standalone

### Decisão: **Manter frontend separado (estratégia B) em Fase 0/1**

**Justificativas:**

1. **Sistema de design proprietário** — `DepthSurface`, `DepthStack`, `DepthSpotlight` com mouse-tracking e `color-mix()` CSS não são replicáveis em Odoo Website sem custo excessivo.
2. **Framer Motion** — animações de scroll e paralaxe presentes em todas as páginas.
3. **Clerk Auth** — integração de autenticação externa que é incompatível com a arquitetura de sessão do Odoo.
4. **Dashboard `/painel`** — evoluirá para dashboard React com dados do Odoo via API, não para backend Odoo.
5. **TanStack Query + Recharts** — pré-configurado para consumo de API em tempo real.

**O que pode migrar em fases futuras:**
- Blog → `website_blog` (quando houver equipe com Odoo)
- Formulário de contacto → `website_form` (lead CRM)
- Páginas legais → Odoo CMS

**Resultado:** `apps/website/` permanece como SPA React durante Fase 0 e Fase 1. Reavaliar na Fase 2.

---

## 5. Campos de Rastreabilidade

Para garantir idempotência e sincronização offline, os seguintes campos de referência são adicionados via `botecopro_core`:

| Modelo Odoo | Campo Adicionado | Tipo | Propósito |
|---|---|---|---|
| `res.partner` | `botecopro_customer_ref` | Char, index | UUID cliente gerado pelo Flutter |
| `pos.order` | `botecopro_client_ref` | Char, index | UUID do pedido gerado offline |
| `pos.order.line` | `botecopro_item_status` | Selection | Status de cozinha por item |

---

## 6. Dívida Técnica Identificada

| # | Item | Prioridade |
|---|---|---|
| 1 | Módulo `mrp` não está em `botecopro_core.depends` — adicionar quando Receitas forem migradas | Média |
| 2 | `pos_restaurant` não está em `botecopro_core.depends` — adicionar quando Mesas forem migradas | Alta |
| 3 | Métodos de pagamento BR (PIX, débito, crédito) precisam de seed data | Alta |
| 4 | `botecopro_item_status` (status de cozinha por item de pedido) não tem equivalente em Odoo standard | Alta |
| 5 | Flutter usa UUIDs como IDs locais; Odoo usa inteiros — estratégia de reconciliação a definir | Alta |
| 6 | Módulo `mrp` pode ser pesado para um bar simples — avaliar alternativa custom simplificada | Baixa |
