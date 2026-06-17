# zensun33/asic — Open-source ASIC development environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends \
    yosys \
    opensta \
    make \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN yosys -V && opensta --version 2>/dev/null || echo "opensta: version check not available"

# OpenROAD is optional. Install if available, skip if not.
RUN apt-get install -y --no-install-recommends openroad 2>/dev/null || \
    echo "openroad: not available via apt, skipping"

COPY fixtures/asic/ /opt/fixtures/asic/

WORKDIR /workspace
CMD ["/bin/bash"]
