# 依存ライブラリ

## FaBoOLED_EROLED096
` $ pip install FaBoOLED_EROLED096`  
https://github.com/FaBoPlatform/FaBoOLED-EROLED096-Python

# 更新履歴
## 2019/8/1
- プログラムの動作確認
- PWM追加

## 2019/7/27
- digin,digout,kyori,oledをdishのredrawとwait仕様に変更

## 2019/7/24
- anain.hsp,angle.hspをHSPのSPIを使う仕様に変更

## 2019/5/22
- anain.hsp,angle.hspをdishで動くように修正

# プログラム  
## アナログ用 
- anain.hsp  
    - touch  
    - angle  
    - distance  
    - ambient light

## ディジタル入力用
- digin.hsp  
    - button  
    - tilt  
    - switch 
    - limit switch  

## ディジタル出力用
- digout.hsp  
    - led  
    - vibe 

## OLED
- oled.hsp

## 応用
- angle.hsp
    - 入力の値によって画像の位置が変わる。
- angle2.hsp
    - 入力の値によって表示する図形と色が変わる。  
- kyori.hsp
    - 距離を測る
