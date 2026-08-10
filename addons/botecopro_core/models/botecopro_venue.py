# -*- coding: utf-8 -*-
"""
BotecoPRO Venue

A Venue represents a physical bar/restaurant establishment.
In Odoo terms it maps primarily to res.company (one Odoo company per venue)
with optional cross-venue management via a parent company.
"""
from odoo import models, fields, api


class BotecoproVenue(models.Model):
    _name = 'botecopro.venue'
    _description = 'BotecoPRO Venue'
    _order = 'name'

    name = fields.Char(required=True, string='Venue Name')
    company_id = fields.Many2one(
        'res.company',
        string='Company',
        required=True,
        ondelete='restrict',
        help='The Odoo company that represents this venue.',
    )
    active = fields.Boolean(default=True)
    timezone = fields.Selection(
        '_tz_get',
        string='Timezone',
        required=True,
        default='America/Sao_Paulo',
    )
    pos_config_ids = fields.One2many(
        'pos.config',
        'botecopro_venue_id',
        string='POS Configurations',
    )
    mobile_sync_enabled = fields.Boolean(
        default=True,
        string='Mobile Sync Enabled',
        help='Allow the Flutter mobile app to sync data for this venue.',
    )

    @api.model
    def _tz_get(self):
        return [(tz, tz) for tz in sorted(
            __import__('pytz').all_timezones, key=lambda x: x
        )]
