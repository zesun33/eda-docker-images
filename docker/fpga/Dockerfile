# zensun33/fpga — Open-source FPGA development environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends \
    yosys \
    nextpnr-generic \
    fpga-icestorm \
    opensta \
    make \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN yosys -V && nextpnr-generic --version 2>/dev/null || true && opensta --version 2>/dev/null || true

COPY fixtures/fpga/ /opt/fixtures/fpga/

WORKDIR /workspace
CMD ["/bin/bash"]
