# Changelog

## [Unreleased]

### Added
- Verilog image: Verilator **5.050** built from source (Ubuntu 24.04 apt is 5.020, below cocotb 2.x's 5.036 floor).
- FPGA image: **openFPGALoader 0.12.1** for ECP5 flashing.

### Changed
- Public image source is GitHub Container Registry (`ghcr.io/zesun33/{verilog,asic,fpga,spice}`), anonymous pull. README is GHCR-first.

## [0.1.0]

### Added
- Skeleton repository structure with shared docs and verify script.
- `docker/verilog/Dockerfile` with iverilog, verilator, python3, make, node.
- `docker/spice/Dockerfile` with ngspice and python3.
- `docker/fpga/Dockerfile` with yosys, nextpnr, opensta.
- `docker/asic/Dockerfile` with yosys and opensta.
- Smoke scripts and fixtures for all four images.
- GitHub Actions verify workflow.
