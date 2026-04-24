#!/bin/bash

# Hata oluşursa durdur
set -e

echo "[INFO]... GStreamer & Build Tools"
sudo apt update
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3.10-dev python3.10-venv

echo "[INFO]... Python 3.10 Virtual Environment"
if [ -d "venv" ]; then
    echo "Cleaning old virtUAL environment..."
    rm -rf venv
fi
python3.10 -m venv venv
source venv/bin/activate

echo "[INFO]... Updating Pip"
pip install --upgrade pip setuptools wheel

echo "[INFO]... CUDA 12.8 Compatible Torch"
pip install torch==2.9.1 torchvision==0.24.1 --index-url https://download.pytorch.org/whl/cu128

echo "[INFO]... Installing Requirements"
cat <<EOT > temp_requirements.txt
ultralytics==8.3.7
matplotlib==3.10.7
numpy==2.2.6
Pillow==11.3.0
PyYAML==6.0.2
requests==2.32.5
scipy==1.15.3
tqdm==4.67.1
pycocotools==2.0.11
tensorboard==2.20.0
pandas==2.3.3
seaborn==0.13.2
psutil==7.0.0
thop==0.1.1-2209072238
easydict==1.13
filterpy==1.4.5
gdown==5.2.0
lapx==0.5.11
EOT

pip install -r temp_requirements.txt
rm temp_requirements.txt

echo "[INFO]... OpenCV with Gstreamer"
export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)

pip install --no-binary opencv-python --no-cache-dir opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON;-DWITH_CUDA=OFF;-DBUILD_EXAMPLES=OFF;-DINSTALL_C_EXAMPLES=OFF;-DBUILD_TESTS=OFF;-DBUILD_PERF_TESTS=OFF"

echo "-------------------------------------------------------"
echo "[INFO]... Completed!"
echo "GStreamer:"
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -i gstreamer
echo "CUDA / GPU Device:"
python3 -c "import torch; print(f'CUDA Aktif: {torch.cuda.is_available()} | Cihaz: {torch.cuda.get_device_name(0)}')"
echo "-------------------------------------------------------"
echo "[WARNING]... Source the Virtual Environment: source venv/bin/activate"
