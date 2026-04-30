#!/bin/bash

# Hata oluşursa betiği durdur
set -e

# CUDA Yollarını Belirle (Ubuntu 22.04 standart konumlar)
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

echo "[INFO]... CUDA_HOME: $CUDA_HOME"
echo "[INFO]... NVCC check: $(which nvcc || echo 'NVCC bulunamadı!')"

# 1. Sistem Paketleri (GStreamer & Derleme Araçları)
echo "[INFO]... GStreamer ve Bağımlılıklar Yükleniyor..."
apt update
apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3-venv \
libgtk2.0-dev libva-dev libvdpau-dev \
ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

# 2. Python Sanal Ortamı
echo "[INFO]... Sanal Ortam Oluşturuluyor..."
[ -d "venv" ] && rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 3. Pip ve Temel Paketler
echo "[INFO]... Python Paketleri Yükleniyor..."
pip install --upgrade pip setuptools wheel
# CUDA 12.1 uyumlu Torch (GTX 1650 için idealdir)
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install numpy matplotlib Pillow PyYAML requests scipy tqdm ultralytics

# 4. OpenCV Derleme (GTX 1650 Özel - Compute Capability 7.5)
echo "[INFO]... OpenCV GStreamer + CUDA (Compute 7.5) Derleniyor..."
echo "[WAIT]... Bu işlem işlemci hızına bağlı olarak 20-40 dakika sürebilir."

# GTX 1650 için mimariyi manuel set ediyoruz (Otomatik bulma bazen Docker'da hata verebilir)
export CUDA_ARCH_BIN=7.5
export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)

pip install -v --no-binary opencv-python --no-cache-dir opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON \
  -DWITH_GTK=ON \
  -DWITH_CUDA=ON \
  -DWITH_CUDNN=ON \
  -DOPENCV_DNN_CUDA=ON \
  -DWITH_NVCUVID=ON \
  -DWITH_NVCUVENC=ON \
  -DCUDA_ARCH_BIN=${CUDA_ARCH_BIN} \
  -DCUDA_FAST_MATH=ON \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTS=OFF"

# 5. Kontrol
echo "-------------------------------------------------------"
echo "[INFO]... Kurulum Tamamlandı! Kontroller yapılıyor:"
python3 -c "import cv2; print('OpenCV GStreamer Desteği:', 'VAR' if 'GStreamer' in cv2.getBuildInformation() else 'YOK')"
python3 -c "import cv2; print('OpenCV CUDA Desteği:', 'VAR' if 'NVIDIA CUDA' in cv2.getBuildInformation() else 'YOK')"
python3 -c "import torch; print(f'Torch CUDA: {torch.cuda.is_available()} | Kart: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'Bulunamadı'}')"
echo "-------------------------------------------------------"
echo "[HAYIRLI OLSUN]... Ortamı aktif etmek için: source venv/bin/activate"
