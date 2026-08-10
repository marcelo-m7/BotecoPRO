# -*- coding: utf-8 -*-
"""
/api/v1/botecopro/auth/*

Authentication endpoints for the Flutter mobile app.

Strategy: Odoo session-based authentication via JSON-RPC /web/session/authenticate
is the primary mechanism. These routes wrap it with BotecoPRO-specific
response formats and JWT-like token hints for offline use.

NOTE: Full JWT / token refresh implementation is planned for Fase 1.
"""
import json
import logging
from odoo import http
from odoo.http import Response, request

_logger = logging.getLogger(__name__)


class BotecoproAuthController(http.Controller):

    @http.route(
        '/api/v1/botecopro/auth/login',
        auth='none',
        type='http',
        methods=['POST'],
        csrf=False,
        cors='*',
    )
    def login(self, **kwargs):
        """
        POST /api/v1/botecopro/auth/login
        Body: { "login": "user@example.com", "password": "..." }
        Returns: { "uid": 1, "name": "...", "session_id": "..." }
        """
        try:
            body = json.loads(request.httprequest.data or '{}')
            login = body.get('login', '')
            password = body.get('password', '')
            db = request.db

            uid = request.session.authenticate(db, login, password)
            if not uid:
                return _json_error('Invalid credentials', 401)

            user = request.env['res.users'].sudo().browse(uid)
            return _json_ok({
                'uid': uid,
                'name': user.name,
                'login': user.login,
                'session_id': request.session.sid,
            })
        except Exception as e:
            _logger.exception('BotecoPRO auth/login error')
            return _json_error(str(e), 500)

    @http.route(
        '/api/v1/botecopro/auth/logout',
        auth='user',
        type='http',
        methods=['POST'],
        csrf=False,
        cors='*',
    )
    def logout(self, **kwargs):
        request.session.logout(keep_db=True)
        return _json_ok({'status': 'logged_out'})


# --------------- helpers -------------------------------------------------------

def _json_ok(data, status=200):
    return Response(
        json.dumps({'ok': True, 'data': data}),
        content_type='application/json',
        status=status,
    )


def _json_error(message, status=400):
    return Response(
        json.dumps({'ok': False, 'error': message}),
        content_type='application/json',
        status=status,
    )
