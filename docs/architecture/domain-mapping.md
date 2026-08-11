# BotecoPRO ↔ Odoo domain mapping

The MVP uses Odoo standard models directly. The mapping below distinguishes
the read-only vertical from later writes.

| Flutter concept | Odoo model | MVP status |
|---|---|---|
| Authenticated user | `res.users` | read |
| Tenant/company | `res.company` | read |
| POS configuration | `pos.config` | read |
| Sellable POS item | `product.product` | read |
| Product template | `product.template` | supporting fields |
| POS category | `pos.category` | read |
| POS currency | `res.currency` | read-only M8 gate |
| POS pricelist | `product.pricelist` | read-only M8 gate; pricing not reproduced |
| Inventory category | `product.category` | future |
| Customer | `res.partner` | future |
| Supplier | `res.partner` | future |
| Restaurant table/floor | `restaurant.table` / `restaurant.floor` | read (M6/M7) |
| POS session | `pos.session` | read-only M8 gate; open/close future |
| POS order/line | `pos.order` / `pos.order.line` | future, controlled write |
| Payment method | `pos.payment.method` | read-only M8 gate |
| Payment | `pos.payment` | future, controlled write |
| Tax/fiscal position | `account.tax` / `account.fiscal.position` | read-only M8 research; no Flutter engine |
| Delivery order/line | `sale.order` / `sale.order.line` | future |
| Inventory | `stock.quant` / `stock.move` | future |
| Employee | `hr.employee` | future |
| Recipe/production | `mrp.bom` / `mrp.production` | future, only if MRP fits |

`product.product` is the app-facing product entity because POS order lines
reference variants. Product queries must use explicit fields, POS availability,
active state, the selected company context and pagination. Prices shown in the
MVP are catalogue values; pricelist, fiscal position, taxes and payment effects
must be validated before any order write.

The initial tenant is `res.users.company_id`. Other companies come from
`res.users.company_ids` and are selected explicitly. Every company-scoped
business-data query must use a restricted `allowed_company_ids` context and must
rely on Odoo ACLs and record rules without `sudo`. Identity lookup and minimal
access probes are not themselves tenant data queries.
