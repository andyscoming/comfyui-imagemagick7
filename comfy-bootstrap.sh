#!/bin/bash

set -e

COMFY_DIR="/workspace/ComfyUI"
VENV="/opt/comfy-venv"
CUSTOM="$COMFY_DIR/custom_nodes"

echo "=== KN-Style Bootstrap Starting ==="

mkdir -p /workspace
mkdir -p "$CUSTOM"

# -------------------------------
# 1. Ensure venv exists
# -------------------------------
if [ ! -d "$VENV" ]; then
    echo "→ Creating persistent venv at $VENV..."
    python3 -m venv "$VENV"
fi

. "$VENV/bin/activate"
pip install --upgrade pip setuptools wheel

# -------------------------------
# 2. Install ComfyUI (persistent)
# -------------------------------
if [ ! -d "$COMFY_DIR" ]; then
    echo "→ Installing ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
    pip install -r "$COMFY_DIR/requirements.txt"
else
    echo "→ Updating ComfyUI..."
    cd "$COMFY_DIR"
    git pull --rebase || true
    pip install -r "$COMFY_DIR/requirements.txt"
fi

# -------------------------------
# 3. Auto-install ComfyUI Manager
# -------------------------------
MANAGER_DIR="$CUSTOM/ComfyUI-Manager"

if [ ! -d "$MANAGER_DIR" ]; then
    echo "→ Installing ComfyUI Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$MANAGER_DIR"
else
    echo "→ Updating ComfyUI Manager..."
    cd "$MANAGER_DIR"
    git pull --rebase || true
fi

# Manager dependencies (persistent)
pip install gitpython

# -------------------------------
# 4. Fix common custom-node deps
# -------------------------------
pip install numba pywt opencv-python

# -------------------------------
# 5. Launch ComfyUI
# -------------------------------
echo "→ Launching ComfyUI..."
cd "$COMFY_DIR"
exec "$VENV/bin/python" main.py $CLI_ARGS
