#!/usr/bin/env bash
# smoke-spice.sh — verify the spice image works
set -euo pipefail

echo "=== SPICE Smoke Test ==="

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURE_DIR="${FIXTURE_DIR:-$ROOT_DIR/fixtures/spice}"

ngspice -v >/tmp/ngspice-version.txt 2>&1 || { echo "FAIL: ngspice not found"; exit 1; }
sed -n '1p' /tmp/ngspice-version.txt
echo "ngspice: OK"

ngspice -b "$FIXTURE_DIR/rc_lowpass.cir" 2>&1 || { echo "FAIL: ngspice simulation"; exit 1; }
echo "ngspice simulation: OK"

echo "=== SPICE Smoke PASS ==="
