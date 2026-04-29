#!/bin/bash


set -e

export CUDA_HOME=/usr
export PATH=$CUDA_HOME/bin:$PATH
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$CUDA_HOME/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

echo "[INFO]... CUDA_HOME set to: $CUDA_HOME"
echo "[INFO]... NVCC check: $(which nvcc)"


echo "[INFO]... GStreamer, NVIDIA Drivers & Build Tools"
sudo apt update
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
gstreamer1.0-libav gstreamer1.0-tools libgstrtspserver-1.0-dev \
build-essential cmake git pkg-config python3-dev python3.10-dev python3.10-venv \
libgtk2.0-dev pkg-config libva-dev libvdpau-dev \
ffmpeg libavcodec-dev libavformat-dev libavutil-dev libswscale-dev


echo "[INFO]... Python 3.10 Virtual Environment"
[ -d "venv" ] && rm -rf venv
python3.10 -m venv venv
source venv/bin/activate

echo "[INFO]... Updating Pip & Installing Requirements"
pip install --upgrade pip setuptools wheel
pip install torch==2.9.1 torchvision==0.24.1 --index-url https://download.pytorch.org/whl/cu128
pip install numpy==2.2.6 matplotlib==3.10.7 Pillow==11.3.0 PyYAML==6.0.2 \
requests==2.32.5 scipy==1.15.3 tqdm==4.67.1 ultralytics==8.3.7


echo "[INFO]... OpenCV with GStreamer & CUDA"


CUDA_ARCH=$(python3 -c "import subprocess; out=subprocess.check_output(['nvidia-smi','--query-gpu=compute_cap','--format=csv,noheader']).decode(); print(out.strip().split('\n')[0])")

export CMAKE_BUILD_PARALLEL_LEVEL=$(nproc)


pip install -v --no-binary opencv-python --no-cache-dir opencv-python==4.10.0.84 \
  --config-settings="cmake.args=-DWITH_GSTREAMER=ON -DWITH_GTK=ON -DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON -DWITH_NVCUVID=ON -DWITH_NVCUVENC=ON -DCUDA_ARCH_BIN=${CUDA_ARCH} -DCUDA_FAST_MATH=ON -DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF"


echo "-------------------------------------------------------"
echo "[INFO]... Completed!"
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -iE "GStreamer|NVIDIA CUDA|NVCUVID"
python3 -c "import torch; print(f'Torch CUDA: {torch.cuda.is_available()} | Device: {torch.cuda.get_device_name(0)}')"
echo "-------------------------------------------------------"
echo "[WARNING]... To activate: source venv/bin/activate"
