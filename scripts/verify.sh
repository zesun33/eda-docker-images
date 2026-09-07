#!/usr/bin/env bash
# verify.sh — run smoke tests for images
# Usage: ./scripts/verify.sh [--quick] [verilog|spice|fpga|asic]
#   --quick skips rebuilds, smokes existing local images only (fast, Podman rootless safe)
#   single name limits to that image (default: all 4)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

QUICK=0
ONLY=""
for arg in "$@"; do
  case "$arg" in
    --quick) QUICK=1 ;;
    verilog|spice|fpga|asic) ONLY="$arg" ;;
    *) echo "Unknown arg: $arg (usage: verify.sh [--quick] [verilog|spice|fpga|asic])" >&2; exit 2 ;;
  esac
done

detect_runtime() {
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        echo docker
        return 0
    fi

    if command -v podman >/dev/null 2>&1; then
        echo podman
        return 0
    fi

    return 1
}

runtime_build_args() {
    local runtime="$1"
    if [ "$runtime" = "podman" ]; then
        printf '%s' '--storage-opt overlay.ignore_chown_errors=true'
    fi
}

color() { printf "\033[1;36m%s\033[0m\n" "$*"; }
ok()    { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
fail()  { printf "  \033[1;31m✗\033[0m %s\n" "$*"; exit 1; }

run_smoke() {
    local runtime="$1"
    local name="$2"
    local build_args
    build_args="$(runtime_build_args "$runtime")"

    if [ "$QUICK" = "1" ]; then
        color "Quick smoke for $name in existing image (no rebuild)..."
        "$runtime" run --rm -v "$ROOT_DIR:/repo:Z" -w /repo "zesun33/$name" bash "scripts/smoke-$name.sh" || fail "smoke $name"
    else
        color "Building $name with $runtime..."
        # shellcheck disable=SC2086
        "$runtime" build $build_args -t "zesun33/$name" -f "docker/$name/Dockerfile" . || fail "build $name"

        color "Running smoke for $name in $runtime..."
        "$runtime" run --rm -v "$ROOT_DIR:/repo:Z" -w /repo "zesun33/$name" bash "scripts/smoke-$name.sh" || fail "smoke $name"
    fi

    ok "$name verified"
}

if runtime="$(detect_runtime)"; then
    color "Using container runtime: $runtime (quick=$QUICK, only=${ONLY:-all})"
    for name in verilog spice fpga asic; do
        if [ -n "$ONLY" ] && [ "$ONLY" != "$name" ]; then
            continue
        fi
        run_smoke "$runtime" "$name"
    done
else
    color "No container runtime available. Checking scripts locally..."
    for name in verilog spice fpga asic; do
        [ -f "scripts/smoke-$name.sh" ] || fail "missing smoke script for $name"
        ok "$name smoke script exists"
    done
fi

color "All images verified."
