FROM ghcr.io/runpod/base:gpu-nvidia-cuda12.1.1-ubuntu22.04

# ------------------------------
# System setup
# ------------------------------
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libde265-dev \
    libjemalloc-dev \
    libtool \
    liblqr-1-0-dev \
    libfftw3-dev \
    libxml2-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------
# Install ImageMagick 7
# ------------------------------
WORKDIR /tmp

RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz && \
    tar xf ImageMagick.tar.gz && \
    cd ImageMagick-* && \
    ./configure --with-modules && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig /usr/local/lib && \
    cd / && rm -rf /tmp/ImageMagick*

# ------------------------------
# Prepare workspace
# ------------------------------
WORKDIR /workspace
RUN mkdir -p /workspace

# ------------------------------
# Copy your bootstrap script
# ------------------------------
COPY comfy-bootstrap.sh /workspace/comfy-bootstrap.sh
RUN chmod +x /workspace/comfy-bootstrap.sh

# ------------------------------
# Entrypoint
# ------------------------------
CMD ["/bin/bash", "/workspace/comfy-bootstrap.sh"]

