#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
VENV_DIR="$REPO_ROOT/.tools/devtools-venv"
PYTHON_BIN="${PYTHON_BIN:-python3}"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "[FAIL] Python 3 não encontrado. Instale Python 3.10 ou superior." >&2
  exit 2
fi

"$PYTHON_BIN" - "$SCRIPT_DIR/toolchain.json" <<'PY'
import json
import sys

expected = tuple(map(int, json.load(open(sys.argv[1], encoding="utf-8"))["python_min"].split(".")))
if sys.version_info[:2] < expected:
    raise SystemExit(f"[FAIL] Python {expected[0]}.{expected[1]}+ é obrigatório; encontrado {sys.version.split()[0]}")
print(f"[PASS] Python {sys.version.split()[0]}")
PY

if [ ! -x "$VENV_DIR/bin/python" ]; then
  echo "[INFO] Criando ambiente virtual em .tools/devtools-venv"
  "$PYTHON_BIN" -m venv "$VENV_DIR"
else
  echo "[PASS] Reutilizando .tools/devtools-venv"
fi

"$VENV_DIR/bin/python" -m pip install --disable-pip-version-check --quiet -r "$SCRIPT_DIR/requirements.txt"

cat <<EOF
[PASS] Bootstrap concluído.

Próximos comandos:
  make doctor
  make verify
  make android-doctor
EOF
