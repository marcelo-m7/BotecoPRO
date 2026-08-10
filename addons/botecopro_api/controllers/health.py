# -*- coding: utf-8 -*-
"""
/api/v1/botecopro/health

Public endpoint for service health and version checks.
"""
import json
from odoo import http
from odoo.http import Response, request

API_VERSION = '1'
BOTECOPRO_VERSION = '0.1.0'


class BotecoproHealthController(http.Controller):

    @http.route(
        '/api/v1/botecopro/health',
        auth='none',
        type='http',
        methods=['GET'],
        csrf=False,
        cors='*',
    )
    def health(self, **kwargs):
        payload = {
            'status': 'ok',
            'api_version': API_VERSION,
            'botecopro_version': BOTECOPRO_VERSION,
        }
        return Response(
            json.dumps(payload),
            content_type='application/json',
            status=200,
        )
