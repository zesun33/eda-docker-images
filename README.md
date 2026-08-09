# eda-docker-images

Container images for hardware development — Verilog simulation, SPICE circuit analysis, FPGA synthesis, and ASIC physical design. Each image is a self-contained environment with pinned tool versions, ready for local dev, CI, and MCP servers.

The repo supports either `docker` or `podman`. If Docker is unavailable, the local verification flow automatically falls back to `podman`.

**Status:** Images build and smoke-test locally. Source will be on GitHub; **Docker Hub publish is pending** (do not assume `docker pull zesun33/...` works yet).

| Image | Base | Tools (measured locally) | Build | Smoke |
|---|---|---|---|---|
| `zesun33/verilog` | ubuntu:24.04 | iverilog 12.0, verilator 5.020, verible, sv2v, svlint, cocotb 2.0.1, python3, make, node | local | local |
| `zesun33/spice` | ubuntu:24.04 | ngspice 42, cocotb 2.0.1, python3 | local | local |
| `zesun33/fpga` | ubuntu:24.04 | yosys **0.38**, icestorm, nextpnr-ice40/ecp5, prjoxide, opensta 2.5.0, openroad 2.0, verible, sv2v, svlint, cocotb 2.0.1 | local | local |
| `zesun33/asic` | ubuntu:24.04 | yosys **0.38**, opensta 2.5.0, openroad 2.0, verible, sv2v, svlint, cocotb 2.0.1 | local | local |

## Quickstart

```bash
# Build all images (fpga/asic are large and slow)
make all

# Run smoke tests inside the built images
make verify

# Build a single image
make build-verilog

# Run a single smoke test (in-container)
make smoke-verilog
```

## Image Contents

### verilog
- `iverilog 12.0` — compile and simulate Verilog
- `verilator 5.020` — lint-only and cycle-accurate simulation
- `verible 0.0-4080` — Verilog/SystemVerilog linter and formatter
- `sv2v 0.0.13` — SystemVerilog to Verilog converter
- `svlint 0.9.5` — SystemVerilog linting rules
- `make` — build automation
- `python3` + `pip` — scripting and cocotb 2.0.1
- `node` + `npm` — MCP server runtime

Note: GUI tooling like `gtkwave` is intentionally omitted in this rootless/headless v1 image because it pulls in desktop packages that are brittle in no-sudo user-namespace environments.

### spice
- `ngspice 42` — circuit simulation
- `cocotb 2.0.1` — Python scripting

### fpga
- `yosys 0.38` — RTL synthesis (conda litex-hub / conda-forge; not 0.51)
- `icestorm` — iCE40 bitstream tools (icepack, iceunpack, icetime, icepll)
- `nextpnr-ice40` — iCE40 place and route (source build)
- `nextpnr-ecp5` — ECP5 place and route (conda litex-hub)
- `prjoxide` — Lattice Nexus bitstream tools + chipdb (Rust build)
- `opensta 2.5.0` — static timing analysis
- `openroad 2.0` — P&R and physical design
- `verible, sv2v, svlint` — RTL linting/format/conversion
- `cocotb 2.0.1` — via system Python (`/usr/bin/python3`); image PATH prefers a shim so `python3` resolves correctly after conda

### asic
- `yosys 0.38` — RTL synthesis
- `opensta 2.5.0` — static timing analysis
- `openroad 2.0` — P&R and physical design
- `verible, sv2v, svlint` — RTL linting/format/conversion
- `cocotb 2.0.1` — same system-Python shim as fpga

## Verification

Run `make verify` to build (if needed) and smoke-test all images in-container. Each smoke test:
1. Verifies the binary exists
2. Checks the version string where available
3. Runs a tiny fixture (verilog sim, spice netlist, yosys synth)

## License

Apache-2.0. See [LICENSE](./LICENSE).
