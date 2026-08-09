#!/usr/bin/env bash
# smoke-asic.sh — verify the asic image works
set -euo pipefail

echo "=== ASIC Smoke Test ==="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE_DIR="${FIXTURE_DIR:-$ROOT_DIR/fixtures/asic}"

PYTHON="${COCOTB_PYTHON:-}"
if [ -z "$PYTHON" ]; then
  if /usr/bin/python3 -c "import cocotb" 2>/dev/null; then
    PYTHON=/usr/bin/python3
  else
    PYTHON=python3
  fi
fi

yosys -V 2>&1 || { echo "FAIL: yosys not found"; exit 1; }
echo "yosys: OK"

# Synthesize tiny_top
cd "$FIXTURE_DIR"
yosys -p "synth -top tiny_top; stat" tiny_top.v 2>&1 || { echo "FAIL: yosys synthesis"; exit 1; }
echo "yosys synthesis: OK"

sta -version 2>&1 || { echo "FAIL: opensta not found"; exit 1; }
echo "opensta: OK"

command -v openroad >/dev/null || { echo "FAIL: openroad not found"; exit 1; }
openroad -version 2>&1 | head -1 || true
echo "openroad: OK"

"$PYTHON" -c "import cocotb; print('cocotb', cocotb.__version__)" || { echo "FAIL: cocotb import"; exit 1; }
echo "cocotb: OK"

echo "=== ASIC Smoke PASS ==="
