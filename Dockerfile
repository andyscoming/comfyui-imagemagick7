FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# -----------------------------------------------------
# System Preparation
# -----------------------------------------------------
RUN apt update -y && apt install -y \
    git wget curl build-essential pkg-config \
    libjpeg-dev libpng-dev libtiff-dev libwebp-dev \
    libfreetype6-dev libfontconfig1-dev \
    libx11-dev libxt-dev libxml2-dev \
    libzip-dev libfftw3-dev libltdl-dev \
    && apt clean

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
# Python venv for ComfyUI
# -----------------------------------------------------
RUN python3 -m venv /opt/comfy-venv && \
    /opt/comfy-venv/bin/pip install --upgrade pip setuptools wheel

# Install Wand inside venv
RUN /opt/comfy-venv/bin/pip install Wand

# -----------------------------------------------------
# Install JupyterLab (system-wide)
# -----------------------------------------------------
RUN pip install --upgrade pip && \
    pip install jupyterlab

# -----------------------------------------------------
# Add bootstrap script (KN-style)
# -----------------------------------------------------
COPY comfy-bootstrap.sh /usr/local/bin/comfy-bootstrap.sh
RUN chmod +x /usr/local/bin/comfy-bootstrap.sh

# -----------------------------------------------------
# Runtime environment
# -----------------------------------------------------
EXPOSE 8188   # ComfyUI
EXPOSE 8888   # JupyterLab

# Default ComfyUI args
ENV CLI_ARGS="--listen 0.0.0.0 --port 8188"

# JupyterLab default args
ENV JUPYTER_ARGS="--ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password=''"

ENTRYPOINT ["/usr/local/bin/comfy-bootstrap.sh"]
