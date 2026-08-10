# Development Guide

Consulte o `README.md` na raiz do repositório para instruções de setup.

## Ambiente Local

```bash
make setup   # Copia .env.example → .env, faz pull das imagens Docker
make up      # Inicia Odoo + PostgreSQL
make logs    # Acompanha os logs
```

## Dependências

- Docker Desktop 24+
- Flutter SDK 3.x
- Python 3.11+
- Node.js 20+

## Convenções

- Conventional Commits (ver AGENTS.md)
- PRs devem ter CI verde antes de merge
- Documenta decisões de arquitetura em `docs/architecture/`
