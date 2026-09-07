# zensun33/fpga — Open-source FPGA development environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/99rootless-no-sandbox

# Install packages available via apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        yosys \
        make \
        python3 \
        python3-pip \
        python3-venv \
        build-essential \
        cmake \
        libboost-dev \
        libboost-program-options-dev \
        libboost-iostreams-dev \
        libboost-thread-dev \
        libeigen3-dev \
        libftdi1-dev \
        libusb-1.0-0-dev \
        curl \
        git \
        libfmt9 \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

RUN yosys -V && python3 --version

RUN python3 -m ensurepip --upgrade 2>/dev/null; \
    python3 -m pip install --upgrade pip 2>/dev/null || true

# Install GL libs separately to avoid fontconfig postinst corruption of dpkg
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgl1 libegl1 \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

# Build icestorm from source
RUN curl -sL https://github.com/YosysHQ/icestorm/archive/refs/tags/v1.1.tar.gz | \
    tar xz -C /tmp && \
    cd /tmp/icestorm-1.1 && \
    make -j$(nproc) CXX=g++ CC=gcc && \
    make install PREFIX=/usr/local && \
    rm -rf /tmp/icestorm-1.1

# Build nextpnr for ice40 from source
RUN curl -sL https://github.com/YosysHQ/nextpnr/archive/refs/tags/nextpnr-0.10.tar.gz | \
    tar xz -C /tmp && \
    cd /tmp/nextpnr-nextpnr-0.10 && \
    mkdir build && cd build && \
    cmake .. -DARCH=ice40 \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_GUI=OFF -DBUILD_PYTHON=OFF \
        -DCMAKE_INSTALL_RPATH="/usr/lib/x86_64-linux-gnu" && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/nextpnr-nextpnr-0.10

# Build prjoxide (Lattice Nexus, requires Rust)
RUN curl -sL https://sh.rustup.rs -o /tmp/rustup.sh && \
    bash /tmp/rustup.sh -y && \
    . "$HOME/.cargo/env" && \
    curl -sL https://github.com/gatecat/prjoxide/archive/refs/heads/master.tar.gz | \
    tar xz -C /tmp && \
    cd /tmp/prjoxide-main/libprjoxide/prjoxide && \
    cargo build --release && \
    PRJOXIDE_BIN=$(find /tmp/prjoxide-main -name "prjoxide" -type f -executable 2>/dev/null | head -1) && \
    cp "$PRJOXIDE_BIN" /usr/local/bin/ && \
    mkdir -p /usr/local/share/prjoxide && \
    cp -r /tmp/prjoxide-main/database /usr/local/share/prjoxide/chipdb && \
    rm -rf /tmp/prjoxide-main /tmp/rustup.sh "$HOME/.cargo" "$HOME/.rustup"

# Install cocotb with system Python
RUN python3 -m pip install --break-system-packages cocotb && \
    python3 -c "import cocotb; print(f'cocotb {cocotb.__version__}')" && \
    icepack --version 2>&1 | head -1 && \
    nextpnr-ice40 --version && \
    command -v prjoxide

# Install unzip for sv2v/svlint downloads
RUN apt-get update && apt-get install -y --no-install-recommends unzip \
    || true; dpkg --force-all --configure -a 2>/dev/null || true; rm -rf /var/lib/apt/lists/*

# Install conda for openroad+sta, nextpnr-ecp5, prjtrellis
RUN curl -sL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh && \
    /opt/conda/bin/conda create -yn sta-env -c litex-hub -c conda-forge -c defaults \
        python=3.10 openroad yosys verible fmt=8.1.1 && \
    /opt/conda/bin/conda create -yn ecp5-env -c litex-hub -c conda-forge -c defaults \
        python=3.7 nextpnr-ecp5 prjtrellis && \
    for bin in sta openroad yosys verible-verilog-lint verible-verilog-format; do \
        ln -sf /opt/conda/envs/sta-env/bin/$bin /opt/conda/bin/$bin 2>/dev/null; \
    done && \
    ln -sf /opt/conda/envs/ecp5-env/bin/nextpnr-ecp5 /opt/conda/bin/nextpnr-ecp5 && \
    for bin in ecppack ecpunpack ecpbram; do \
        ln -sf /opt/conda/envs/ecp5-env/bin/$bin /opt/conda/bin/$bin 2>/dev/null; \
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

ENV PATH="/opt/conda/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/conda/envs/sta-env/lib:/opt/conda/lib:$LD_LIBRARY_PATH"

# cocotb is installed for system Python; keep /usr/bin/python3 as the default
# interpreter so `python3 -c "import cocotb"` works after conda PATH prepend.
RUN printf '#!/bin/sh\nexec /usr/bin/python3 "$@"\n' > /usr/local/bin/python3 && \
    chmod +x /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    PATH="/usr/local/bin:$PATH" python3 -c "import cocotb; print(f'cocotb {cocotb.__version__}')"

ENV PATH="/usr/local/bin:/opt/conda/bin:$PATH"

RUN yosys -V && sta -version && nextpnr-ecp5 --version && ecppack --help 2>&1 | head -1 && openroad -version && \
    verible-verilog-lint --version && sv2v --version && svlint --version && \
    python3 -c "import cocotb; print(cocotb.__version__)"

COPY fixtures/fpga/ /opt/fixtures/fpga/

WORKDIR /workspace
CMD ["/bin/bash"]
