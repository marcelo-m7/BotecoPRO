# botecopro_api

REST API addon for the BotecoPRO Flutter mobile app.

## Base URL

```
http(s)://<odoo-host>/api/v1/botecopro/
```

## Endpoints (Fase 0)

| Method | Path              | Auth   | Description              |
|--------|-------------------|--------|--------------------------|
| GET    | `/health`         | none   | Service health + version |
| POST   | `/auth/login`     | none   | Login                    |
| POST   | `/auth/logout`    | user   | Logout                   |

## Planned (Fase 1+)

```
GET  /bootstrap          – initial data sync
GET  /products           – product catalogue
GET  /categories         – categories
GET  /customers          – customer list
POST /customers          – create/update customer
GET  /orders             – order list
POST /orders             – create order
POST /orders/:id/pay     – register payment
POST /sync               – incremental sync push
```

See `docs/api/README.md` for full contract documentation.
