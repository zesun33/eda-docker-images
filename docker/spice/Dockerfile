# zensun33/spice — SPICE circuit simulation environment

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/99rootless-no-sandbox

# fontconfig postinst scripts fail in rootless podman; ignore and force-configure later
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ngspice \
        python3 \
        python3-pip \
        python3-venv \
        make \
    || true; \
    dpkg --force-all --configure -a 2>/dev/null || true; \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages cocotb && \
    ngspice -v && python3 --version

COPY fixtures/spice/ /opt/fixtures/spice/

WORKDIR /workspace
CMD ["/bin/bash"]
