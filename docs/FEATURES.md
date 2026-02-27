# 要求仕様と実装について
Raspberry Pi OS 拡張の変更内容や教科書の内容変更について記録する。

## 01 章のための変更
デフォルトの デスクトップ背景を `clouds.jpg` に固定。`contrib/scripts/install.bash`。
##  02 章のための変更
OpenHSP をインストール。 `contrib/OpenHSP`

OpenHSP で GPIO, I2C 等基本的な 外付けハードウェアインターフェースを使用するためのファイルをインストール。 `contrib/FaBo`
##  03 章のための変更
##  04 章のための変更
##  05 章のための変更
赤外線機能を有効化。 `contrib/scripts/install.bash`

SPI機能を有効化。 `contrib/scripts/install.bash`

I2C機能を有効化。 `contrib/scripts/install.bash`

OpenHSP で ADC 等の外付けハードウェアインターフェースを使用するためのファイルをインストール。 `contrib/FaBo`

OpenHSP で 赤外線通信に関する外付けハードウェアインターフェースを使用するためのファイルをインストール。 `contrib/IR`
##  06 章のための変更
openjtalk をインストール。`contrib/scripts/install.bash`

julius をインストール。`contrib/Julius`, `contrib/Dictationkit`, 各 `Makefile.am`

openjtalk を OpenHSP で使用するためのファイルをインストール。`contrib/OpenJTalk`, 各 `Makefile.am`

julius を OpenHSP で使用するためのファイルをインストール。`contrib/JuliusMisc`, 各 `Makefile.am`

##  07 章のための変更
webserver 用の OpenHSP 拡張をインストール。 `contrib/OpenHSPUtil`

HTML 編集の OpenHSP 拡張をインストール。 `contrib/HTMLParse`
##  08 章のための変更
##  共通
`/etc/itschool_distro_bersion_info` にコミットハッシュを含める。`contrib/scripts/install.bash`

`fcitx5` と `mozc` による日本語入力をサポート。`contrib/scripts/install.bash`
