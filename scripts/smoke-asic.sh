#!/usr/bin/env bash
# smoke-asic.sh — verify the asic image works
set -euo pipefail

echo "=== ASIC Smoke Test ==="

yosys -V 2>&1 || { echo "FAIL: yosys not found"; exit 1; }
echo "yosys: OK"

# Synthesize tiny_top
cd /opt/fixtures/asic
yosys -p "synth -top tiny_top; stat" tiny_top.v 2>&1 || { echo "FAIL: yosys synthesis"; exit 1; }
echo "yosys synthesis: OK"

echo "=== ASIC Smoke PASS ==="
