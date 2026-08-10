# -*- coding: utf-8 -*-
"""
Extends res.partner with BotecoPRO-specific customer fields.
"""
from odoo import models, fields


class ResPartner(models.Model):
    _inherit = 'res.partner'

    botecopro_customer_ref = fields.Char(
        string='BotecoPRO Client ID',
        help='UUID assigned by the mobile app for offline-first identification.',
        index=True,
    )
    botecopro_loyalty_points = fields.Integer(
        string='Loyalty Points',
        default=0,
    )
    botecopro_preferred_venue_id = fields.Many2one(
        'botecopro.venue',
        string='Preferred Venue',
    )
