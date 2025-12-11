FROM ghcr.io/runpod/base:cuda12.1.1

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

WORKDIR /tmp

RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz && \
    tar xf ImageMagick.tar.gz && \
    cd ImageMagick-* && \
    ./configure --with-modules && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig /usr/local/lib && \
    cd / && rm -rf /tmp/ImageMagick*

WORKDIR /workspace
RUN mkdir -p /workspace

COPY comfy-bootstrap.sh /workspace/comfy-bootstrap.sh
RUN chmod +x /workspace/comfy-bootstrap.sh

CMD ["/bin/bash", "/workspace/comfy-bootstrap.sh"]
