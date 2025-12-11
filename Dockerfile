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
    ldconfig && \
    magick --version

# -----------------------------------------------------
# Install ComfyUI + venv + dependencies
# -----------------------------------------------------
WORKDIR /workspace

# Create ComfyUI directory
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI

# Python virtual environment
RUN python3 -m venv /workspace/ComfyUI/venv && \
    . /workspace/ComfyUI/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel

# Install ComfyUI requirements
RUN . /workspace/ComfyUI/venv/bin/activate && \
    pip install -r /workspace/ComfyUI/requirements.txt

# -----------------------------------------------------
# Install Wand + optional ImageMagick Python deps
# -----------------------------------------------------
RUN . /workspace/ComfyUI/venv/bin/activate && \
    pip install Wand

# -----------------------------------------------------
# (Optional) Install common ComfyUI custom nodes
# -----------------------------------------------------
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Manager

# -----------------------------------------------------
# Runtime environment
# -----------------------------------------------------
EXPOSE 8188

ENV CLI_ARGS="--listen 0.0.0.0 --port 8188"

CMD ["/bin/bash", "-c", "cd /workspace/ComfyUI && /workspace/ComfyUI/venv/bin/python main.py $CLI_ARGS"]
