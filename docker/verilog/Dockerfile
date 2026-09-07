# zensun33/verilog — Verilog/SystemVerilog development environment
# Built from ubuntu:24.04 base
# Pinned tool versions in docker/verilog/versions.env

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Copy version pins
COPY docker/verilog/versions.env /opt/versions.env

# Rootless podman on shared systems may not support the default `_apt`
# sandbox user because no subordinate UID/GID ranges are configured.
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/99rootless-no-sandbox

# Install system packages (build-essential for Verilator --binary/coverage C++ builds)
RUN apt-get update && apt-get install -y --no-install-recommends \
    iverilog \
    verilator \
    build-essential \
    make \
    python3 \
    libpython3.12 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --break-system-packages cocotb

# Install verible (Verilog linter/formatter)
RUN curl -sL https://github.com/chipsalliance/verible/releases/download/v0.0-4080-ga0a8d8eb/verible-v0.0-4080-ga0a8d8eb-linux-static-x86_64.tar.gz | \
    tar xz -C /tmp && \
    cp /tmp/verible-v0.0-4080-ga0a8d8eb/bin/* /usr/local/bin/ && \
    rm -rf /tmp/verible-v0.0-4080-ga0a8d8eb

# Install sv2v (SystemVerilog to Verilog converter)
RUN curl -sL https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip -o /tmp/sv2v.zip && \
    unzip -o /tmp/sv2v.zip -d /tmp/sv2v-extract && \
    cp /tmp/sv2v-extract/sv2v-Linux/sv2v /usr/local/bin/ && \
    rm -rf /tmp/sv2v.zip /tmp/sv2v-extract

# Install svlint (SystemVerilog linter)
RUN curl -sL https://github.com/dalance/svlint/releases/download/v0.9.5/svlint-v0.9.5-x86_64-lnx.zip -o /tmp/svlint.zip && \
    mkdir -p /tmp/svlint-extract && \
    unzip -o /tmp/svlint.zip -d /tmp/svlint-extract && \
    cp /tmp/svlint-extract/bin/* /usr/local/bin/ && \
    rm -rf /tmp/svlint.zip /tmp/svlint-extract

# Smoke test: verify installed tools
RUN iverilog -V && \
    verilator --version && \
    g++ --version && \
    python3 --version && \
    node --version && \
    make --version && \
    verible-verilog-lint --version && \
    sv2v --version && \
    svlint --version

# Copy fixtures for testing
COPY fixtures/verilog/ /opt/fixtures/verilog/

WORKDIR /workspace
CMD ["/bin/bash"]
