FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# -----------------------------------------------------
# System Preparation
# -----------------------------------------------------
RUN apt update -y && apt install -y \
    git wget curl build-essential pkg-config \
    libjpeg-dev libpng-dev libtiff-dev libwebp-dev \
    libfreetype6-dev libfontconfig1-dev \
    libx11-dev libxt-dev libxml2-dev \
    libzip-dev libfftw3-dev libltdl-dev

# -----------------------------------------------------
# Install ImageMagick 7 from source
# -----------------------------------------------------
WORKDIR /tmp

RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz && \
    tar -xvf ImageMagick.tar.gz && \
    cd ImageMagick-* && \
    ./configure --with-modules=yes --enable-shared && \
    make -j"$(nproc)" && \
    make install && \
    ldconfig

# -----------------------------------------------------
# Install Python venv for ComfyUI
# -----------------------------------------------------
RUN python3 -m venv /opt/comfy-venv && \
    /opt/comfy-venv/bin/pip install --upgrade pip setuptools wheel

# Install Wand (Python bindings for ImageMagick)
RUN /opt/comfy-venv/bin/pip install Wand

# -----------------------------------------------------
# Add bootstrap script (KN-style)
# -----------------------------------------------------
COPY comfy-bootstrap.sh /usr/local/bin/comfy-bootstrap.sh
RUN chmod +x /usr/local/bin/comfy-bootstrap.sh

# -----------------------------------------------------
# Runtime environment
# -----------------------------------------------------
EXPOSE 8188
ENV CLI_ARGS="--listen 0.0.0.0 --port 8188"

ENTRYPOINT ["/usr/local/bin/comfy-bootstrap.sh"]
