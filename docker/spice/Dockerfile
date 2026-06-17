# zensun33/spice — SPICE circuit simulation environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ngspice \
    python3 \
    python3-pip \
    python3-venv \
    make \
    gnuplot \
    && rm -rf /var/lib/apt/lists/*

RUN ngspice -v && python3 --version

COPY fixtures/spice/ /opt/fixtures/spice/

WORKDIR /workspace
CMD ["/bin/bash"]
