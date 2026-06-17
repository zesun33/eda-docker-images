# zensun33/verilog — Verilog/SystemVerilog development environment
# Built from ubuntu:24.04 base
# Pinned tool versions in docker/verilog/versions.env

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

# Copy version pins
COPY docker/verilog/versions.env /opt/versions.env

# Install system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    iverilog \
    verilator \
    gtkwave \
    make \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pipx for isolated tool installs
RUN python3 -m pip install --no-cache-dir pipx \
    && pipx ensurepath

# Smoke test: verify installed tools
RUN iverilog -V && \
    verilator --version && \
    python3 --version && \
    node --version && \
    make --version

# Copy fixtures for testing
COPY fixtures/verilog/ /opt/fixtures/verilog/

WORKDIR /workspace
CMD ["/bin/bash"]
