FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    wget \
    git \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libwebp-dev \
    libde265-dev \
    libheif-dev \
    libx265-dev \
    libjemalloc-dev \
    libtool \
    liblqr-1-0-dev \
    libfftw3-dev \
    libxml2-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libopenjp2-7-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxcb1-dev \
    zlib1g-dev \
    liblzma-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Build ImageMagick 7
WORKDIR /tmp
RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick-7.1.1-39.tar.gz && \
    tar xf ImageMagick-7.1.1-39.tar.gz && \
    cd ImageMagick-7.1.1-39 && \
    ./configure --with-modules --enable-shared --with-quantum-depth=16 && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig && \
    cd / && rm -rf /tmp/ImageMagick-7.1.1-39*

WORKDIR /workspace
RUN mkdir -p /workspace

COPY comfy-bootstrap.sh /workspace/comfy-bootstrap.sh
RUN chmod +x /workspace/comfy-bootstrap.sh

CMD ["/bin/bash", "/workspace/comfy-bootstrap.sh"]



