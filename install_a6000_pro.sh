#!/bin/bash

# Hata oluşursa durdur
set -e

# --- 1. CUDA YOLLARI (Sistem dizinindeki kurulumu baz alır) ---
export CUDA_HOME=/usr
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$CUDA_HOME/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

echo "[INFO]... CUDA_HOME: $CUDA_HOME"
echo "[INFO]... NVCC check: $(which nvcc)"

# --- 2. SİSTEM BAĞIMLILIKLARI ---
echo "[INFO]... Installing GStreamer & Build Tools"
sudo apt update
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3.10-dev python3.10-venv \
libgtk2.0-dev pkg-config libva-dev libvdpau-dev \
ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

# --- 3. VIRTUAL ENV VE PYTHON PAKETLERİ ---
echo "[INFO]... Setting up Virtual Environment"
[ -d "venv" ] && rm -rf venv
python3.10 -m venv venv
source venv/bin/activate

echo "[INFO]... Updating Pip & Core Packages"
pip install --upgrade pip setuptools wheel
# CUDA 12.8 için en güncel Torch sürümü
pip install torch==2.9.1 torchvision==0.24.1 --index-url https://download.pytorch.org/whl/cu128
pip install numpy==2.2.6 matplotlib==3.10.7 Pillow==11.3.0 PyYAML==6.0.2 \
requests==2.32.5 scipy==1.15.3 tqdm==4.67.1 ultralytics==8.3.7

# --- 4. OPENCV DERLEME (RTX 6000 Ada / Blackwell Optimized) ---
echo "[INFO]... Building OpenCV with GStreamer & CUDA"

# Mimariyi otomatik tespit eder (RTX 6000 Ada için 8.9, Blackwell için muhtemelen 10.x olacaktır)
CUDA_ARCH=$(python3 -c "import subprocess; out=subprocess.check_output(['nvidia-smi','--query-gpu=compute_cap','--format=csv,noheader']).decode(); print(out.strip().split('\n')[0])")
echo "[INFO]... Detected CUDA Compute Capability: $CUDA_ARCH"

export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)

# Blackwell/Ada mimarisi için spesifik optimizasyonlarla OpenCV kurulumu
pip install -v --no-binary opencv-python --no-cache-dir opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON -DWITH_GTK=ON -DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON -DWITH_NVCUVID=ON -DWITH_NVCUVENC=ON -DCUDA_ARCH_BIN=${CUDA_ARCH} -DCUDA_FAST_MATH=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF"

# --- 5. SON KONTROL ---
echo "-------------------------------------------------------"
echo "[INFO]... Build Completed Successfully!"
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -iE "GStreamer|NVIDIA CUDA|NVCUVID"
python3 -c "import torch; print(f'Torch CUDA: {torch.cuda.is_available()} | Device: {torch.cuda.get_device_name(0)}')"
echo "-------------------------------------------------------"
echo "[WARNING]... Aktif etmek için: source venv/bin/activate"
