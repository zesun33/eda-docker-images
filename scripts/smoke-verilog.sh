#!/usr/bin/env bash
# smoke-verilog.sh — verify the verilog image works
set -euo pipefail

echo "=== Verilog Smoke Test ==="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE_DIR="${FIXTURE_DIR:-$ROOT_DIR/fixtures/verilog}"

iverilog -V >/tmp/iverilog-version.txt 2>&1 || { echo "FAIL: iverilog not found"; exit 1; }
sed -n '1p' /tmp/iverilog-version.txt
verilator --version >/tmp/verilator-version.txt 2>&1 || { echo "FAIL: verilator not found"; exit 1; }
sed -n '1p' /tmp/verilator-version.txt
echo "iverilog + verilator: OK"

# Verify cocotb and libpython shared library resolution
cocotb-config --version >/dev/null 2>&1 || { echo "FAIL: cocotb-config not found"; exit 1; }
python3 -c "import find_libpython; assert find_libpython.find_libpython() is not None, 'libpython shared library not found'" || { echo "FAIL: find_libpython resolution"; exit 1; }
echo "cocotb + libpython: OK"

# Compile and simulate counter
cd "$FIXTURE_DIR"
iverilog -o counter_sim counter.v counter_tb.v 2>&1 || { echo "FAIL: compilation"; exit 1; }
vvp counter_sim 2>&1 | grep -q "PASS" || { echo "FAIL: simulation"; exit 1; }
echo "counter compile + simulate: PASS"

echo "=== Verilog Smoke PASS ==="
