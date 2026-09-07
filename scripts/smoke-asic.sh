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

# Signoff tools (Phase 1): KLayout / Magic / Netgen / SymbiYosys / volare
klayout -v 2>&1 | head -1 || { echo "FAIL: klayout not found"; exit 1; }
echo "klayout: OK"

magic -dnull -noconsole /dev/null 2>&1 | head -2 || { echo "FAIL: magic not found"; exit 1; }
echo "magic: OK"

(/usr/lib/netgen/bin/netgen -batch 2>&1 | grep -q "Netgen 1.5") || { echo "FAIL: netgen not found"; exit 1; }
echo "netgen: OK (headless -batch; Tk wrapper netgen-lvs needs DISPLAY, expected headless)"

sby --help 2>&1 | head -1 || { echo "FAIL: sby not found"; exit 1; }
echo "symbiyosys: OK"

volare --help 2>&1 | head -1 || { echo "FAIL: volare not found"; exit 1; }
echo "volare: OK (PDKs downloaded on first run, not baked)"

"$PYTHON" -c "import cocotb; print('cocotb', cocotb.__version__)" || { echo "FAIL: cocotb import"; exit 1; }
echo "cocotb: OK"

echo "=== ASIC Smoke PASS ==="
