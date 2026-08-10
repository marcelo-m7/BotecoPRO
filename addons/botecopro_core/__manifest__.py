# -*- coding: utf-8 -*-
{
    'name': 'BotecoPRO Core',
    'summary': 'Core domain extensions for bars and restaurants',
    'description': """
BotecoPRO Core
==============
Extends Odoo standard models with bar/restaurant-specific fields and logic.
This addon is the foundation for all other botecopro_* addons.
    """,
    'version': '17.0.0.1.0',
    'category': 'Point of Sale',
    'author': 'BotecoPRO',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'point_of_sale',
        'sale',
        'stock',
        'hr',
        'account',
    ],
    'data': [
        'security/ir.model.access.csv',
        'views/botecopro_venue_views.xml',
        'data/botecopro_data.xml',
    ],
    'installable': True,
    'application': False,
    'auto_install': False,
}
