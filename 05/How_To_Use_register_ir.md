# register\_irの使い方

ターミナルでregister\_irをタイプしたあと、下記太字の例にならってに情報 (リモコン名、信号名) を入力していきます。

-----

pi@localhost$ sudo ./register\_ir  
リモコンの名前を入力してください。**fan**  
信号の名前を入力してください。終了する場合はCtrl+Dを押してください。**onoff**  
赤外線を照射してください  
照射が終わったらqを入力した後Enterを押してください  
space 123  
pulse 456  
space 789  
**q**  
信号の名前を入力してください。終了する場合はCtrl+Dを押してください。**direction**  
赤外線を照射してください  
照射が終わったらqを入力した後Enterを押してください  
space 123  
pulse 456  
space 789  
pulse 012  
space 345  
pulse 678  
space 901  
pulse 234  
space 567  
pulse 890  
**q**  
信号の名前を入力してください。終了する場合はCtrl+Dを押してください。**Ctrl+Dを押す**  
信号の登録が完了しました。以下のコマンドでlircdを再起動してください。  
sudo systemctl restart lircd  
以下のコマンドをタイプして赤外線を送信できます  
irsend SEND\_ONCE fan 信号名  

-----

以上でirsendコマンドによって登録した赤外線を発信できるようになりました。
