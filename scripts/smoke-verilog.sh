#!/usr/bin/env bash
# smoke-verilog.sh — verify the verilog image works
set -euo pipefail

echo "=== Verilog Smoke Test ==="

iverilog -V 2>&1 | head -1 || { echo "FAIL: iverilog not found"; exit 1; }
verilator --version 2>&1 || { echo "FAIL: verilator not found"; exit 1; }
echo "iverilog + verilator: OK"

# Compile and simulate counter
cd /opt/fixtures/verilog
iverilog -o counter_sim counter.v counter_tb.v 2>&1 || { echo "FAIL: compilation"; exit 1; }
vvp counter_sim 2>&1 | grep -q "PASS" || { echo "FAIL: simulation"; exit 1; }
echo "counter compile + simulate: PASS"

echo "=== Verilog Smoke PASS ==="
