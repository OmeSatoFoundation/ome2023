#!/bin/bash
python3 -m venv myenv
source myenv/bin/activate
sudo apt update
pip3 install ultralytics
python test_yolov8.py

