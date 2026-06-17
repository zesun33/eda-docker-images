# eda-docker-images

Pre-built Docker images for hardware development — Verilog simulation, SPICE circuit analysis, FPGA synthesis, and ASIC physical design. Each image is a self-contained environment with pinned tool versions, ready for local dev, CI, and MCP servers.

| Image | Base | Tools | Size |
|---|---|---|---|
| `zesun33/verilog` | ubuntu:24.04 | iverilog, verilator, gtkwave, python3, make, node | |
| `zesun33/spice` | ubuntu:24.04 | ngspice, python3, plotting deps | |
| `zesun33/fpga` | ubuntu:24.04 | yosys, nextpnr, opensta | |
| `zesun33/asic` | ubuntu:24.04 | yosys, opensta, openroad (optional) | |

## Quickstart

```bash
# Build all images
make all

# Run smoke tests
make verify

# Build a single image
make build-verilog

# Run a single smoke test
make smoke-verilog
```

## Image Contents

### verilog
- `iverilog` — compile and simulate Verilog
- `verilator` — lint-only and cycle-accurate simulation
- `gtkwave` — waveform viewer
- `make` — build automation
- `python3` + `pip` / `uv` — scripting and cocotb
- `node` + `npm` — MCP server runtime

### spice
- `ngspice` — circuit simulation
- `python3` + plotting dependencies

### fpga
- `yosys` — RTL synthesis
- `nextpnr` — place and route
- `opensta` — static timing analysis

### asic
- `yosys` — RTL synthesis
- `opensta` — static timing analysis
- `openroad` — P&R (bundled if image size allows)

## Verification

Run `make verify` to run smoke tests for all images. Each smoke test:
1. Verifies the binary exists
2. Checks the version string
3. Runs a tiny fixture

## License

Apache-2.0. See [LICENSE](./LICENSE).
