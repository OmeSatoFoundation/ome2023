from ultralytics import YOLO
# Load the YOLOv8 model
model = YOLO("yolov8n.pt")
results = model(0, show=True) #カメラ番号を入力
for i in enumerate(results):
    print(i)
