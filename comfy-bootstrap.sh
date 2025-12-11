#!/bin/bash
set -e

echo "=== Updating system ==="
apt update
apt install -y \
    python3-venv python3-dev python3-pip python3-wheel python3-setuptools \
    build-essential pkg-config git wget curl \
    libjpeg-dev libpng-dev libtiff-dev libwebp-dev \
    libfreetype6-dev libfontconfig1-dev \
    libxml2-dev libxslt1-dev zlib1g-dev \
    libgl1 libglib2.0-0

echo "=== Ensuring pip ==="
python3 -m ensurepip --upgrade || true
python3 -m pip install --upgrade pip setuptools wheel

echo "=== Installing ALL required Python deps ==="
python3 -m pip install \
    pillow \
    requests \
    tqdm \
    matplotlib \
    toml \
    scikit-image \
    PyWavelets \
    scipy \
    aiohttp \
    safetensors \
    typing_extensions

echo "=== Installing ComfyUI (if missing) ==="
if [ ! -d /workspace/ComfyUI ]; then
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
fi

echo "=== Installing ComfyUI-Manager ==="
if [ ! -d /workspace/ComfyUI/custom_nodes/ComfyUI-Manager ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
        /workspace/ComfyUI/custom_nodes/ComfyUI-Manager
fi

echo "=== Installing RES4LYF ==="
if [ ! -d /workspace/ComfyUI/custom_nodes/RES4LYF ]; then
    git clone https://github.com/RES4LYF/RES4LYF.git \
        /workspace/ComfyUI/custom_nodes/RES4LYF
fi

echo "=== Fixing permissions ==="
chmod -R 777 /workspace/ComfyUI

echo "=== Starting ComfyUI ==="
cd /workspace/ComfyUI
python3 main.py --listen --port 8188
