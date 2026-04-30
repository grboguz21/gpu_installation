#!/bin/bash

# Hata oluşursa dur, tanımlanmamış değişkenleri hata say
set -e

# 1. CUDA Yollarını Tanımla (Derleyicinin nvcc'yi görmesi için şart)
export CUDA_HOME=/usr/local/cuda
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

echo "-------------------------------------------------------"
echo "[INFO]... Donanım Kontrolü:"
nvidia-smi --query-gpu=name,driver_version,compute_cap --format=csv,noheader
echo "[INFO]... NVCC Versiyon:"
nvcc --version
echo "-------------------------------------------------------"

# 2. Sistem Paketlerini Güncelle ve Bağımlılıkları Kur
echo "[INFO]... GStreamer, GTK ve Build Araçları Yükleniyor..."
apt update
apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3-venv \
libgtk2.0-dev libva-dev libvdpau-dev \
ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev

# 3. Python Sanal Ortamı (venv) Hazırlığı
echo "[INFO]... Python Sanal Ortamı Kuruluyor..."
[ -d "venv" ] && rm -rf venv
python3 -m venv venv
source venv/bin/activate

# 4. Temel Python Paketleri ve PyTorch (CUDA 12.1 uyumlu)
echo "[INFO]... Pip Güncelleniyor ve Paketler Yükleniyor..."
pip install --upgrade pip setuptools wheel
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121
pip install numpy matplotlib Pillow PyYAML requests scipy tqdm ultralytics \
pycocotools tensorboard pandas seaborn psutil thop easydict filterpy gdown lapx

# 5. OpenCV'yi Kaynaktan Derle (GTX 1650 İçin Özel)
echo "[INFO]... OpenCV 4.10 GStreamer + CUDA (7.5) Derleniyor..."
echo "[WAIT]... Bu işlem 20-40 dakika sürebilir, işlemciye yük biner."

# GTX 1650 için mimari: 7.5
export CUDA_ARCH_BIN=7.5
export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)

# Not: Eski kalıntı kalmaması için no-cache-dir ve v-verbose kullanıyoruz
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
  -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTS=OFF"

# 6. Doğrulama Testi (Tırnak hatası giderilmiş hali)
echo "-------------------------------------------------------"
echo "[INFO]... KURULUM BİTTİ! DURUM RAPORU:"

python3 -c "
import cv2
import torch
info = cv2.getBuildInformation()
print(f'-> OpenCV GStreamer: {\"VAR\" if \"GStreamer\" in info else \"YOK\"}')
print(f'-> OpenCV CUDA: {\"VAR\" if \"NVIDIA CUDA\" in info else \"YOK\"}')
print(f'-> Torch CUDA: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'-> Aktif GPU: {torch.cuda.get_device_name(0)}')
"
echo "-------------------------------------------------------"
echo "[DİKKAT]... Docker'dan çıkmadan önce commit yapmayı unutma!"
echo "[DİKKAT]... Aktifleştirmek için: source venv/bin/activate"
