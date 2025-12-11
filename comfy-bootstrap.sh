#!/bin/bash
set -e

COMFY_DIR="/workspace/ComfyUI"
VENV="/opt/comfy-venv"

echo "=== Custom ComfyUI Bootstrap Starting ==="

mkdir -p /workspace

# ---------------------------------------------------------
# Activate Python environment
# ---------------------------------------------------------
if [ ! -d "$VENV" ]; then
    echo "ERROR: Missing venv at $VENV"
    exit 1
fi

. "$VENV/bin/activate"

# ---------------------------------------------------------
# Install ComfyUI (persistent)
# ---------------------------------------------------------
if [ ! -d "$COMFY_DIR" ]; then
    echo "→ ComfyUI not found. Installing fresh..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
    pip install -r "$COMFY_DIR/requirements.txt"
else
    echo "→ ComfyUI found. Updating..."
    cd "$COMFY_DIR"
    git pull --rebase || true
    pip install -r "$COMFY_DIR/requirements.txt"
fi

# ---------------------------------------------------------
# Custom Nodes Auto-Install (Persistent)
# ---------------------------------------------------------
CUSTOM="$COMFY_DIR/custom_nodes"

mkdir -p "$CUSTOM"

# ComfyUI Manager
if [ ! -d "$CUSTOM/ComfyUI-Manager" ]; then
    echo "→ Installing ComfyUI Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$CUSTOM/ComfyUI-Manager"
else
    echo "→ Updating ComfyUI Manager..."
    cd "$CUSTOM/ComfyUI-Manager"
    git pull --rebase || true
fi

# WAS Node Suite
if [ ! -d "$CUSTOM/was-node-suite-comfyui" ]; then
    echo "→ Installing WAS Node Suite..."
    git clone https://github.com/WASasquatch/was-node-suite-comfyui "$CUSTOM/was-node-suite-comfyui"
fi

# RES4LYF (optional)
if [ ! -d "$CUSTOM/RES4LYF" ]; then
    echo "→ Installing RES4LYF..."
    git clone https://github.com/RES4LYF/RES4LYF "$CUSTOM/RES4LYF"
fi

# ---------------------------------------------------------
# Install Python dependencies required by custom nodes
# ---------------------------------------------------------
echo "→ Installing custom-node Python dependencies..."

pip install \
    gitpython \
    numba \
    PyWavelets \
    opencv-python-headless \
    pillow==10.4.0 \
    --quiet

echo "→ Dependencies installed."

# ---------------------------------------------------------
# Launch ComfyUI
# ---------------------------------------------------------
echo "→ Launching ComfyUI..."
cd "$COMFY_DIR"
exec python main.py $CLI_ARGS
