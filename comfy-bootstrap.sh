#!/bin/bash
set -e

### ─────────────────────────────────────────────
### PATHS
### ─────────────────────────────────────────────
COMFY_DIR="/workspace/ComfyUI"
VENV_DIR="/opt/comfy-venv"

echo "=== Custom KN-Style Bootstrap Starting ==="

mkdir -p /workspace

### ─────────────────────────────────────────────
### 1. CREATE PYTHON VENV (PERSISTENT ACROSS RESTARTS)
### ─────────────────────────────────────────────
if [ ! -d "$VENV_DIR" ]; then
    echo "→ Creating virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

# Activate venv
. "$VENV_DIR/bin/activate"

python3 -m pip install --upgrade pip setuptools wheel

### ─────────────────────────────────────────────
### 2. INSTALL SYSTEM PACKAGES (ON POD IMAGE)
### ─────────────────────────────────────────────
echo "→ Installing system dependencies..."
apt update
apt install -y \
    git \
    build-essential \
    libgl1 \
    ffmpeg \
    python3-dev

### ─────────────────────────────────────────────
### 3. INSTALL OR UPDATE COMFYUI
### ─────────────────────────────────────────────
if [ ! -d "$COMFY_DIR" ]; then
    echo "→ ComfyUI not found. Cloning fresh copy..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
else
    echo "→ ComfyUI found. Pulling updates..."
    cd "$COMFY_DIR"
    git pull --rebase || true
fi

echo "→ Installing ComfyUI base requirements..."
pip install -r "$COMFY_DIR/requirements.txt"

### ─────────────────────────────────────────────
### 4. INSTALL COMFYUI MANAGER + DEPENDENCIES
### ─────────────────────────────────────────────
MANAGER_DIR="$COMFY_DIR/custom_nodes/ComfyUI-Manager"

if [ ! -d "$MANAGER_DIR" ]; then
    echo "→ Installing ComfyUI-Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
else
    echo "→ Updating ComfyUI-Manager..."
    cd "$MANAGER_DIR"
    git pull --rebase || true
fi

echo "→ Installing Manager Python packages..."
pip install \
    gitpython \
    aiohttp \
    toml \
    tqdm

### ─────────────────────────────────────────────
### 5. EXTRA DEPENDENCIES NEEDED BY COMMON NODES
### (WAS Suite, RES4LYF, Metadata-SG, etc.)
### ─────────────────────────────────────────────
echo "→ Installing additional custom node dependencies..."
pip install \
    opencv-python \
    matplotlib \
    safetensors \
    numba \
    pywavelets

### ─────────────────────────────────────────────
### 6. LAUNCH COMFYUI
### ─────────────────────────────────────────────
echo "→ Launching ComfyUI..."
cd "$COMFY_DIR"

exec python main.py --listen --port 8188 --enable-cors-header "*"
