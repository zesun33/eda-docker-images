#!/usr/bin/env bash
# smoke-fpga.sh — verify the fpga image works
set -euo pipefail

echo "=== FPGA Smoke Test ==="

yosys -V 2>&1 || { echo "FAIL: yosys not found"; exit 1; }
echo "yosys: OK"

# Synthesize blinky
cd /opt/fixtures/fpga
yosys -p "synth_ice40 -top blinky -json blinky.json" blinky.v 2>&1 || { echo "FAIL: yosys synthesis"; exit 1; }
echo "yosys synthesis: OK"

echo "=== FPGA Smoke PASS ==="
