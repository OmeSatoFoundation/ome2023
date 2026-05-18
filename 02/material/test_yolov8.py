from ultralytics import YOLO
import cv2
 
def object_detection(img, model):
    """ 画像とモデルを受け取って物体検出する関数 """
 
    # 物体検出
    results = model(img)
 
    # バウンディングボックスをオーバーレイ
    img_annotated = results[0].plot()
 
    # 物体検出結果画像を表示
    cv2.imshow("Result", img_annotated)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
 
    return
 
 
if __name__ == '__main__':
    """ Main """
 
    # サンプル画像（ultralyticsインストールフォルダのassetに入っている）
    # インポートしたパッケージのディレクトリはprint(cv2.__path__)等で確認可能。
    img1 = 'test.jpg'
 
    # モデルを設定
    model = YOLO('yolov8n.pt')
 
    # 物体検出関数を実行
    object_detection(img1, model)
