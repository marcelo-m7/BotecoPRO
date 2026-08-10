# -*- coding: utf-8 -*-
{
    'name': 'BotecoPRO API',
    'summary': 'REST API layer for Flutter mobile app and external integrations',
    'description': """
BotecoPRO API
=============
Exposes versioned REST endpoints under /api/v1/botecopro/ for:
- Authentication
- Bootstrap (initial data sync)
- Products & categories
- Customers
- Orders
- Payments
- Sync (incremental)

All endpoints return JSON and follow the contracts defined in
packages/api_contracts/.
    """,
    'version': '17.0.0.1.0',
    'category': 'Technical',
    'author': 'BotecoPRO',
    'license': 'LGPL-3',
    'depends': [
        'botecopro_core',
        'web',
    ],
    'data': [],
    'installable': True,
    'application': False,
    'auto_install': False,
}
