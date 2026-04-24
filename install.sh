#!/bin/bash

# Herhangi bir hatada scripti durdur
set -e

echo "--- 1. GStreamer ve Build Sistem Bağımlılıkları Kuruluyor ---"
sudo apt update
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3.10-dev python3.10-venv

echo "--- 2. Python 3.10 Sanal Ortam Oluşturuluyor ---"
# Eski venv varsa temizle (opsiyonel)
# rm -rf venv
python3.10 -m venv venv
source venv/bin/activate

echo "--- 3. Pip ve Temel Araçlar Güncelleniyor ---"
pip install --upgrade pip setuptools wheel

echo "--- 4. CUDA 12.8 - PyTorch Kuruluyor (RTX A4000 için) ---"
pip install torch==2.9.1 torchvision==0.24.1 --index-url https://download.pytorch.org/whl/cu128

echo "--- 5. requirements.txt Paketleri Yükleniyor ---"
pip install -r requirements.txt

echo "--- 6. OpenCV GStreamer Desteğiyle Derleniyor (Vakit alabilir) ---"
# Python 3.10 kullandığımız için derleme hatası almayacaksın
pip install --no-binary opencv-python opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON;-DWITH_CUDA=OFF;-DBUILD_EXAMPLES=OFF;-DINSTALL_C_EXAMPLES=OFF;-DBUILD_TESTS=OFF;-DBUILD_PERF_TESTS=OFF"

echo "-------------------------------------------------------"
echo "Kurulum Başarıyla Tamamlandı!"
echo "GStreamer Durumu: "
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -i gstreamer
echo "-------------------------------------------------------"
echo "Sanal ortamı aktif etmek için şu komutu kullanın:"
echo "source venv/bin/activate"
