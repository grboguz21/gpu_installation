# GPU & Vision Setup (RTX A4000)

This script automates the installation of **OpenCV with GStreamer support**, **PyTorch (CUDA)**, and **YOLO** on Ubuntu. 
It solves the compatibility issues between versions of different tools by using a stable **Python 3.10** environment.

## Features
* **OpenCV + GStreamer:** Built from source for low-latency robotics video streams.
* **GPU:** NVIDIA RTX A4000 and CUDA 12.8.
* **Libraries:** Ultralytics and all necessary dependencies.

## Installation

Run these commands in your terminal:

```bash
git clone https://github.com/grboguz21/gpu_installation
cd ./gpu_installation
```

Install dependencies with the commands below:

```bash
chmod +x install_a4000.sh
./install_a4000.sh
```

## What's Included?
* **Python 3.10** Virtual Environment
* **OpenCV 4.10** (with GStreamer)
* **PyTorch 2.9.1** (CUDA 12.8)
* **Ultralytics** (All YOLO versions)
* **Tracking Tools:** Filterpy, Lapx, Thop, and more.

## Verification

After installation, verify the setup:

```bash
source venv/bin/activate
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -i gstreamer
```
*You should see: `GStreamer: YES (1.x.x)`*
