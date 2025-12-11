#!/bin/bash

set -e

COMFY_DIR="/workspace/ComfyUI"
VENV="/opt/comfy-venv"

echo "=== KN-Style Bootstrap Starting ==="

# Create workspace directory if missing
mkdir -p /workspace

# If ComfyUI is not installed on the network disk, install it
if [ ! -d "$COMFY_DIR" ]; then
    echo "→ ComfyUI not found. Installing into $COMFY_DIR..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
    . "$VENV/bin/activate"
    pip install -r "$COMFY_DIR/requirements.txt"
else
    echo "→ ComfyUI found. Updating..."
    cd "$COMFY_DIR"
    git pull --rebase
    . "$VENV/bin/activate"
    pip install -r "$COMFY_DIR/requirements.txt"
fi

echo "→ Launching ComfyUI..."
cd "$COMFY_DIR"
exec "$VENV/bin/python" main.py $CLI_ARGS
