SHELL := /usr/bin/env bash

.PHONY: all build-verilog build-spice build-fpga build-asic \
        smoke-verilog smoke-spice smoke-fpga smoke-asic verify clean

all: build-verilog build-spice build-fpga build-asic

build-verilog:
	docker build -t zesun33/verilog -f docker/verilog/Dockerfile .

build-spice:
	docker build -t zesun33/spice -f docker/spice/Dockerfile .

build-fpga:
	docker build -t zesun33/fpga -f docker/fpga/Dockerfile .

build-asic:
	docker build -t zesun33/asic -f docker/asic/Dockerfile .

smoke-verilog:
	bash scripts/smoke-verilog.sh

smoke-spice:
	bash scripts/smoke-spice.sh

smoke-fpga:
	bash scripts/smoke-fpga.sh

smoke-asic:
	bash scripts/smoke-asic.sh

verify:
	bash scripts/verify.sh

clean:
	docker rmi zesun33/verilog zesun33/spice zesun33/fpga zesun33/asic 2>/dev/null || true
