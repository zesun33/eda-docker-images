SHELL := /usr/bin/env bash
CONTAINER_RUNTIME ?= $(shell if command -v docker >/dev/null 2>&1; then echo docker; elif command -v podman >/dev/null 2>&1; then echo podman; else echo docker; fi)
CONTAINER_BUILD_ARGS ?= $(shell if [ "$(CONTAINER_RUNTIME)" = "podman" ]; then echo --storage-opt overlay.ignore_chown_errors=true; fi)

.PHONY: all build-verilog build-spice build-fpga build-asic \
        smoke-verilog smoke-spice smoke-fpga smoke-asic verify clean

all: build-verilog build-spice build-fpga build-asic

build-verilog:
	$(CONTAINER_RUNTIME) build $(CONTAINER_BUILD_ARGS) -t zesun33/verilog -f docker/verilog/Dockerfile .

build-spice:
	$(CONTAINER_RUNTIME) build $(CONTAINER_BUILD_ARGS) -t zesun33/spice -f docker/spice/Dockerfile .

build-fpga:
	$(CONTAINER_RUNTIME) build $(CONTAINER_BUILD_ARGS) -t zesun33/fpga -f docker/fpga/Dockerfile .

build-asic:
	$(CONTAINER_RUNTIME) build $(CONTAINER_BUILD_ARGS) -t zesun33/asic -f docker/asic/Dockerfile .

smoke-verilog:
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR):/repo:Z" -w /repo zesun33/verilog bash scripts/smoke-verilog.sh

smoke-spice:
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR):/repo:Z" -w /repo zesun33/spice bash scripts/smoke-spice.sh

smoke-fpga:
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR):/repo:Z" -w /repo zesun33/fpga bash scripts/smoke-fpga.sh

smoke-asic:
	$(CONTAINER_RUNTIME) run --rm -v "$(CURDIR):/repo:Z" -w /repo zesun33/asic bash scripts/smoke-asic.sh

verify:
	bash scripts/verify.sh

clean:
	$(CONTAINER_RUNTIME) rmi zesun33/verilog zesun33/spice zesun33/fpga zesun33/asic 2>/dev/null || true
