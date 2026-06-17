#!/usr/bin/env bash
# smoke-spice.sh — verify the spice image works
set -euo pipefail

echo "=== SPICE Smoke Test ==="

ngspice -v 2>&1 | head -1 || { echo "FAIL: ngspice not found"; exit 1; }
echo "ngspice: OK"

ngspice -b /opt/fixtures/spice/rc_lowpass.cir 2>&1 || { echo "FAIL: ngspice simulation"; exit 1; }
echo "ngspice simulation: OK"

echo "=== SPICE Smoke PASS ==="
