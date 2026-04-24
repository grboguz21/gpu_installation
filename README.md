# GPU & Vision Setup (RTX A4000)

One-click installer for **OpenCV (GStreamer)**, **PyTorch (CUDA)**, and **YOLO** on Ubuntu (24.0x). 
It uses **Python 3.10** to ensure maximum stability for Computer Vision projects.

## Installation

Run the commands below one by one:
```bash
git clone https://github.com/grboguz21/gpu_installation
cd gpu_installation
chmod +x install_a4000.sh
./install_a4000.sh
```
After installation finished, you should be able to see this:
```bash
GStreamer: YES (1.24.2)
CUDA: True | Device: NVIDIA RTX A4000
```

## Features
* **OpenCV 4.10:** Built from source with **GStreamer** support.
* **GPU Ready:** Pre-configured for **NVIDIA RTX A4000** (CUDA 12.8).
* **YOLO & Tracking:** Includes Ultralytics, Filterpy, and Lapx.

## Verification

```bash
source venv/bin/activate
python3 -c "import cv2; print(cv2.getBuildInformation())" | grep -i gstreamer
```
*Expected output: `GStreamer: YES`*

---

## ✉️ Support & Contact
If you encounter any issues or have questions, feel free to open an **Issue** on this repository or contact me directly through this page.
