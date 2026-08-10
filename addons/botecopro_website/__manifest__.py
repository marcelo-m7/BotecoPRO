# -*- coding: utf-8 -*-
{
    'name': 'BotecoPRO Website',
    'summary': 'Odoo Website integration for BotecoPRO public pages',
    'description': """
BotecoPRO Website
=================
Extends Odoo Website with BotecoPRO branding and public pages:
- Landing page
- Pricing/plans
- Feature showcase
- Contact form

NOTE: This addon is prepared but not fully populated in Fase 0.
The decision between Odoo Website vs. standalone frontend is
documented in docs/architecture/domain-mapping.md.
    """,
    'version': '17.0.0.1.0',
    'category': 'Website',
    'author': 'BotecoPRO',
    'license': 'LGPL-3',
    'depends': [
        'botecopro_core',
        'website',
    ],
    'data': [],
    'assets': {},
    'installable': True,
    'application': False,
    'auto_install': False,
}
