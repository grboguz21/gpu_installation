#!/bin/bash

set -e

echo "---  GStreamer ---"
sudo apt update
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3-venv python3-full

echo "--- Virtual Environment ---"
# rm -rf venv 
python3 -m venv venv
source venv/bin/activate

echo "--- System Update ---"
pip install --upgrade pip setuptools wheel

echo "---  CUDA 12.8 - PyTorch ---"
pip install torch==2.9.1 torchvision==0.24.1 --index-url https://download.pytorch.org/whl/cu128

echo "---  requirements.txt packages ---"
pip install -r requirements.txt

echo "--- Building Opencv with Gstreamer ---"
pip install --no-binary opencv-python opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON;-DWITH_CUDA=OFF;-DBUILD_EXAMPLES=OFF;-DINSTALL_C_EXAMPLES=OFF;-DBUILD_TESTS=OFF;-DBUILD_PERF_TESTS=OFF"

echo "-------------------------------------------------------"
echo "Completed.."
echo "GStreamer Activated: "
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -i gstreamer
echo "-------------------------------------------------------"
echo "Source Environment: source venv/bin/activate"
