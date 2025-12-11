#!/bin/bash
set -e

echo "=== Persistent ComfyUI Bootstrap Starting ==="

### ─────────────────────────────────────────────
### PATHS (Persistent!)
### ─────────────────────────────────────────────
COMFY_DIR="/workspace/ComfyUI"
VENV_DIR="/workspace/comfy-venv"
CUSTOM_DIR="$COMFY_DIR/custom_nodes"


### ─────────────────────────────────────────────
### 1. CREATE VENV IN /workspace (PERSISTENT)
### ─────────────────────────────────────────────
if [ ! -d "$VENV_DIR" ]; then
    echo "→ Creating persistent virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

# Activate venv
. "$VENV_DIR/bin/activate"

python3 -m pip install --upgrade pip setuptools wheel


### ─────────────────────────────────────────────
### 2. SYSTEM PACKAGES (Container-only, fast)
### ─────────────────────────────────────────────
apt update
apt install -y git build-essential libgl1 ffmpeg python3-dev


### ─────────────────────────────────────────────
### 3. INSTALL OR UPDATE COMFYUI
### ─────────────────────────────────────────────
if [ ! -d "$COMFY_DIR" ]; then
    echo "→ Cloning ComfyUI into /workspace"
    git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFY_DIR"
else
    echo "→ Updating ComfyUI"
    cd "$COMFY_DIR"
    git pull --rebase || true
fi

echo "→ Installing ComfyUI dependencies"
pip install -r "$COMFY_DIR/requirements.txt"


### ─────────────────────────────────────────────
### 4. INSTALL COMFYUI MANAGER + DEPS
### ─────────────────────────────────────────────
MANAGER_DIR="$CUSTOM_DIR/ComfyUI-Manager"

if [ ! -d "$MANAGER_DIR" ]; then
    echo "→ Installing ComfyUI Manager"
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$MANAGER_DIR"
else
    echo "→ Updating ComfyUI Manager"
    cd "$MANAGER_DIR"
    git pull --rebase || true
fi

echo "→ Installing Manager Python dependencies"
pip install gitpython aiohttp toml tqdm


### ─────────────────────────────────────────────
### 5. INSTALL EXTRA DEPS FOR CUSTOM NODES (WAS, RES4LYF, etc.)
### ─────────────────────────────────────────────
echo "→ Installing common custom node dependencies"
pip install \
    opencv-python \
    matplotlib \
    safetensors \
    numba \
    pywavelets


### ─────────────────────────────────────────────
### 6. AUTO-INSTALL MODEL DOWNLOADER NODE
### ─────────────────────────────────────────────
if [ ! -d "$CUSTOM_DIR/comfyui-model-downloader" ]; then
    echo "→ Installing Model Downloader Node"
    git -C "$CUSTOM_DIR" clone https://github.com/dsigmabcn/comfyui-model-downloader.git
else
    echo "→ Updating Model Downloader Node"
    cd "$CUSTOM_DIR/comfyui-model-downloader"
    git pull --rebase || true
fi


### ─────────────────────────────────────────────
### 7. LAUNCH COMFYUI
### ─────────────────────────────────────────────
echo "→ Launching ComfyUI"
cd "$COMFY_DIR"

exec python main.py --listen --port 8188 --enable-cors-header "*"
