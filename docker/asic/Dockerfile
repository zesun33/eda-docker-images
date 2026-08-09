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
    for bin in sta openroad yosys verible-verilog-lint verible-verilog-format; do \
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

ENV PATH="/opt/conda/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/conda/envs/openroad-env/lib:/opt/conda/lib:$LD_LIBRARY_PATH"

# cocotb is installed for system Python; keep /usr/bin/python3 as the default
# interpreter so `python3 -c "import cocotb"` works after conda PATH prepend.
RUN printf '#!/bin/sh\nexec /usr/bin/python3 "$@"\n' > /usr/local/bin/python3 && \
    chmod +x /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    PATH="/usr/local/bin:$PATH" python3 -c "import cocotb; print(f'cocotb {cocotb.__version__}')"

ENV PATH="/usr/local/bin:/opt/conda/bin:$PATH"

RUN yosys -V && sta -version && openroad -version && \
    verible-verilog-lint --version && sv2v --version && svlint --version && \
    python3 -c "import cocotb; print(cocotb.__version__)"

COPY fixtures/asic/ /opt/fixtures/asic/

WORKDIR /workspace
CMD ["/bin/bash"]
