#!/usr/bin/env bash
# smoke-fpga.sh — verify the fpga image works
set -euo pipefail

echo "=== FPGA Smoke Test ==="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE_DIR="${FIXTURE_DIR:-$ROOT_DIR/fixtures/fpga}"

# Prefer system Python for cocotb (installed before conda PATH override).
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

command -v icepack >/dev/null || { echo "FAIL: icepack not found"; exit 1; }
echo "icepack: OK"

command -v openroad >/dev/null || { echo "FAIL: openroad not found"; exit 1; }
openroad -version 2>&1 | head -1 || true
echo "openroad: OK"

"$PYTHON" -c "import cocotb; print('cocotb', cocotb.__version__)" || { echo "FAIL: cocotb import"; exit 1; }
echo "cocotb: OK"

# Synthesize blinky
cd "$FIXTURE_DIR"
yosys -p "synth_ice40 -top blinky -json blinky.json" blinky.v 2>&1 || { echo "FAIL: yosys synthesis"; exit 1; }
echo "yosys synthesis: OK"

echo "=== FPGA Smoke PASS ==="
