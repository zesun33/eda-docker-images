# zensun33/asic — Open-source ASIC development environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/99rootless-no-sandbox

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        yosys \
        make \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        git \
        unzip \
        libfmt9 \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m ensurepip --upgrade 2>/dev/null; \
    python3 -m pip install --upgrade pip 2>/dev/null || true

# Install GL libs separately to avoid fontconfig postinst corruption of dpkg
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgl1 libegl1 \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

# Install cocotb with system Python before conda PATH override
RUN python3 -m pip install --break-system-packages cocotb && \
    yosys -V

# Install conda + openroad+sta (needs separate env, Python 3.10)
RUN curl -sL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh && \
    /opt/conda/bin/conda create -yn openroad-env -c litex-hub -c conda-forge -c defaults \
        python=3.10 openroad yosys verible fmt=8.1.1 && \
    for bin in sta openroad yosys yosys-abc yosys-smtbmc yosys-witness verible-verilog-lint verible-verilog-format; do \
        ln -sf /opt/conda/envs/openroad-env/bin/$bin /opt/conda/bin/$bin 2>/dev/null; \
    done && \
    /opt/conda/bin/conda clean -afy

# Install sv2v and svlint (not on conda)
RUN mkdir -p /tmp/sv2v-extract /tmp/svlint-extract && \
    curl -sL https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip -o /tmp/sv2v.zip && \
    unzip -o /tmp/sv2v.zip -d /tmp/sv2v-extract && \
    cp /tmp/sv2v-extract/sv2v-Linux/sv2v /usr/local/bin/ && \
    curl -sL https://github.com/dalance/svlint/releases/download/v0.9.5/svlint-v0.9.5-x86_64-lnx.zip -o /tmp/svlint.zip && \
    unzip -o /tmp/svlint.zip -d /tmp/svlint-extract && \
    cp /tmp/svlint-extract/bin/* /usr/local/bin/ && \
    rm -rf /tmp/sv2v.zip /tmp/svlint.zip /tmp/sv2v-extract /tmp/svlint-extract

# Signoff tools: KLayout (GDS/DRC), Magic (extraction), Netgen (LVS), z3 (SMT solver)
# NOTE: gtkwave intentionally omitted (desktop deps brittle rootless); use VCD parsers in mcp-verilog/mcp-wave.
# NOTE: symbiyosys + volare via pip below (not in apt). PDKs NOT baked (volare download on first run to keep image lean).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        klayout \
        magic \
        netgen-lvs \
        z3 \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

# Modern z3 SMT solver for SBY (apt z3 is 4.8.12 from 2020 and crashes on
# current SMT2; pip z3-solver ships no CLI). Pinned GitHub release binary.
RUN mkdir -p /tmp/z3-extract && \
    curl -sL https://github.com/Z3Prover/z3/releases/download/z3-5.1.0/z3-5.1.0-x64-glibc-2.39.zip -o /tmp/z3.zip && \
    unzip -o -q /tmp/z3.zip -d /tmp/z3-extract && \
    cp /tmp/z3-extract/z3-5.1.0-x64-glibc-2.39/bin/z3 /usr/local/bin/ && \
    rm -rf /tmp/z3.zip /tmp/z3-extract && \
    z3 --version

# SymbiYosys (formal) from source — NOT on PyPI (only stale conda builds exist).
# SBY v0.68 via make install; needs z3 (/usr/local/bin above) + yosys-smtbmc (conda yosys) at runtime.
RUN rm -rf /tmp/sby && git clone --depth 1 https://github.com/YosysHQ/sby.git /tmp/sby && \
    make -C /tmp/sby install PREFIX=/usr/local && \
    rm -rf /tmp/sby && \
    sby --help 2>&1 | head -2

# volare (PDK manager) via pip — PDKs NOT baked (download on first run to keep image lean).
RUN /usr/bin/python3 -m pip install --break-system-packages volare && \
    volare --help 2>&1 | head -2

ENV PATH="/opt/conda/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/conda/envs/openroad-env/lib:/opt/conda/lib:$LD_LIBRARY_PATH"

# cocotb is installed for system Python; keep /usr/bin/python3 as the default
# interpreter so `python3 -c "import cocotb"` works after conda PATH prepend.
RUN printf '#!/bin/sh\nexec /usr/bin/python3 "$@"\n' > /usr/local/bin/python3 && \
    chmod +x /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    PATH="/usr/local/bin:$PATH" python3 -c "import cocotb; print(f'cocotb {cocotb.__version__}')"

ENV PATH="/usr/local/bin:/opt/conda/bin:$PATH"

RUN yosys -V && yosys-abc -help 2>&1 | head -1 || true && z3 --version && sta -version && openroad -version && \
    verible-verilog-lint --version && sv2v --version && svlint --version && \
    klayout -v 2>&1 | head -2 && \
    magic -dnull -noconsole /dev/null 2>&1 | head -2 && \
    /usr/lib/netgen/bin/netgen -batch 2>&1 | grep -q "Netgen 1.5" && \
    sby --help 2>&1 | head -2 && \
    volare --help 2>&1 | head -2 && \
    python3 -c "import cocotb; print(cocotb.__version__)"

COPY fixtures/asic/ /opt/fixtures/asic/

WORKDIR /workspace
CMD ["/bin/bash"]
