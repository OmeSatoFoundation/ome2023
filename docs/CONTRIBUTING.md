# 開発者向けガイド (Contribution Guide)

本プロジェクト **ome2023** は、子ども向けプログラミング教材の演習環境を提供するリポジトリです。演習は Raspberry Pi 上で行われ、リポジトリをビルドすると演習用にカスタマイズされた Raspberry Pi OS のイメージファイル (`.img`) が生成されます。このドキュメントでは、新しく開発に参加する方向けに、プロジェクトの構成や開発の流れ、テスト方法、そしてベースの Raspberry Pi OS からの主な変更点について説明します。

## プロジェクト概要

- **目的**: Raspberry Pi 上で動作する子ども向けプログラミング演習環境の提供。8つの演習セクションがあり、各セクションごとにサンプルプログラムや教材を収録しています。ビルドの結果、これら教材や必要なソフトウェアを含んだ Raspberry Pi OS (64-bit, Bullseye) のカスタムイメージが得られます。
- **構成**: リポジトリ直下に `01/` ～ `08/` のディレクトリがあり、それぞれ第1～8節の教材（サンプルコード、素材、演習用プログラムなど）を含みます。そのほか、全セクション共通で使用するプログラムやライブラリ、開発環境（例: OpenHSP SDK）を `contrib/` 配下に格納。ビルドスクリプトや Docker/Vagrant 設定なども含まれています。

## ディレクトリ構成

```
ome2023/
├── 01/, 02/, ... 08/        各演習セクション用ディレクトリ（第1～8章の教材）
│   ├── *.hsp 等             HSP言語のサンプルコード、演習用スクリプト
│   ├── *.png, *.wav 等      プログラミングで利用する画像・音声などの素材
│   └── www/, cgi-bin/      （章によって）ウェブ関連ファイルやCGIスクリプト
├── contrib/                共通プログラム・サードパーティライブラリなど
│   ├── OpenHSP/            OpenHSP SDK 本体（HSPランタイム・エディタ等）
│   ├── OpenHSPUtil/        HSP向けユーティリティモジュール
│   ├── FaBo/               環境センサーボード制御コード
│   ├── IR/                 赤外線リモコン制御モジュール
│   ├── Julius/             Julius 音声認識エンジン（ソースサブモジュール）
│   ├── JuliusMisc/         Julius 関連の辞書・設定ファイル
│   ├── OpenJTalk/          日本語音声合成エンジンの辞書・設定
│   ├── Dictationkit/       Dictation Kit 音声認識モデル
│   ├── HTMLParse/          HTML解析ライブラリ
│   └── WebServer/          簡易 Web サーバ実装
├── contrib/scripts/        ビルド・インストール用スクリプト
│   └── install.bash        イメージ作成＆インストールスクリプト
├── docs/                   ドキュメント類（VM ビルド手順など）
├── vm/                     Vagrant 設定ファイル
├── Dockerfile              ビルド用 Docker イメージ定義
├── Makefile.am             Automake 定義
├── configure.ac            Autoconフ設定
└── README.md               基本的なビルド手順・依存関係説明
```

### 各ディレクトリの役割

- **`01/`～`08/`**: 各章の教材一式。HSPスクリプト、HTML/CGI、画像・音声素材など。
- **`contrib/OpenHSP`**: HSP ランタイム／エディタをクロスコンパイルするソース一式。
- **`contrib/OpenHSPUtil`**: HSP からハードウェア制御等を行うユーティリティモジュール。
- **`contrib/FaBo`**: 環境センサー（BME280等）制御用スクリプト・コマンド。
- **`contrib/IR`**: LIRC と連携した赤外線リモコン入出力モジュール。
- **`contrib/Julius`**, **`contrib/JuliusMisc`**: Julius 音声認識エンジン本体と辞書/モデル。
- **`contrib/OpenJTalk`**: Open JTalk 音声合成用辞書・設定。
- **`contrib/Dictationkit`**: Dictation Kit 音声認識モデル。
- **`contrib/HTMLParse`**: Web 演習向け HTML パースライブラリ。
- **`contrib/WebServer`**: Python ベースの組込 Web サーバスクリプト。

## ビルド方法

### 1. クロスコンパイルによるイメージ作成 (x86_64)

1. **準備**  
   - Git LFS のインストール・初期化  
   - Docker、`qemu-user-static`、binfmt 設定  

2. **リポジトリ取得**  
   ```bash
   git clone --recurse-submodules git@github.com:OmeSatoFoundation/ome2023.git
   ```

3. **Docker イメージ作成**  
   ```bash
   docker build . -t ome2023
   ```

4. **ビルド & インストール**  
   ```bash
   docker run --rm -ti --privileged      -v $(pwd):/work -w /work      -v /dev/:/dev      -v $SSH_AUTH_SOCK:/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent      ome2023 sh -c '
       aclocal -I m4 && automake -a -c && autoconf &&        ./configure --build=x86_64-linux-gnu --host=aarch64-linux-gnu --prefix=/usr/local &&        make -j$(nproc) && ./contrib/scripts/install.bash -f
     '
   ```
   生成された `itschool-raspbian-*.img` を取得。

5. **注意**  
   - 古い `.img` は事前に削除  
   - サブモジュール更新後は必ず `git submodule update --init`

### 2. Raspberry Pi (arm64) 上でのネイティブビルド

1. **依存パッケージ**  
   ```bash
   sudo apt update
   sudo apt install build-essential autoconf automake libtool      libasound2-dev libgtk2.0-dev libsdl2-dev libglew-dev      libegl1-mesa-dev libgles2-mesa-dev libgpiod-dev      i2c-tools lirc libcurl4-openssl-dev open-jtalk      open-jtalk-mecab-naist-jdic fcitx-mozc dnsutils      nmap telnet gimp vlc
   ```

2. **リポジトリ取得**  
   ```bash
   git clone --recurse-submodules git@github.com:OmeSatoFoundation/ome2023.git
   git lfs install && git lfs pull
   ```

3. **ビルド & インストール**  
   ```bash
   cd ome2023
   aclocal -I m4 && automake -a -c && autoconf
   ./configure --prefix=/usr/local
   make -j$(nproc)
   sudo make install
   ```

4. **システム設定**  
   - `raspi-config` で I2C / SPI を有効化  
   - `/boot/config.txt` に  
     ```
     dtoverlay=gpio-ir,gpio_pin=4
     dtoverlay=gpio-ir-tx,gpio_pin=13
     ```
   - `/etc/lirc/lirc_options.conf` を適切に設定  
   - 日本語入力・ロケール設定（`ja_JP.UTF-8`、Mozc）

## バグ修正・開発の流れ

1. **原因箇所の特定**  
   - 教材スクリプト（章ディレクトリ内の `.hsp`）  
   - ハード制御 → `contrib/FaBo` や `contrib/IR`  
   - 音声認識/合成 → `contrib/Julius*`・`contrib/OpenJTalk`

2. **コード変更**  
   - HSP スクリプトは該当 `.hsp` を編集  
   - 共通ライブラリは `contrib/` 配下を編集

3. **ビルド & インストール**  
   - 開発フェーズは Raspberry Pi 上で直接再コンパイル  
   - 必要に応じてクロスコンパイルしてイメージ生成

4. **テスト**  
   - 以下「テストの実行方法」参照

5. **教材ファイルリスト更新**  
   ```bash
   find 01 02 03 04 05 06 07 08 -type f | sort > new_list.txt
   # Makefile.am の nobase_dist_omedata_DATA セクションを更新
   ```

6. **コミット & PR 作成**  
   - トピックブランチで作業  
   - コミットメッセージに Issue 番号を含めると良い  
   - master へのプルリクエストを作成

## テストの実行方法

- **開発フェーズでの実機テスト**  
  Raspberry Pi 上でソースコードを直接編集・再コンパイルし、その場で動作確認を行います。  
  例: OpenHSP ランタイムのバグ修正時は、  
  ```bash
  cd contrib/OpenHSP
  make && sudo make install
  ```  
  で再ビルド＆インストールし、修正後のランタイムでスクリプトを実行して動作を確認します。

- **イメージビルド後の実機テスト**  
  リポジトリに取り込んだパッチを反映して新たに `.img` をビルドし、そのイメージを Raspberry Pi に書き込んでテストします。このテストでは、変更がビルドプロセスに正しく組み込まれているか、および他のコンポーネントとの衝突がないかを確認します。

## Raspberry Pi OS への主なカスタマイズ

- **教育用ソフトウェアの追加**  
  - OpenHSP (HSP3 エディタ／ランタイム)  
  - Julius 音声認識エンジン＋日本語モデル  
  - Open JTalk 音声合成エンジン＋辞書  
  - Tux Typing, VLC, GIMP, TypingTutor 等  

- **システム設定**  
  - I2C / SPI インターフェース有効化  
  - 赤外線リモコン機能 (GPIO4, 13 に overlay)  
  - LIRC 設定 `/dev/lirc0` 固定  
  - 日本語入力 & ロケール設定 (`ja_JP.UTF-8`)

- **教材配置**  
  `/usr/local/share/ome/01`〜`08` に各章の教材を配置。

- **バージョン情報**  
  `/etc/itschool_distro_version_info` にコミットハッシュを記録。

## おわりに

ome2023プロジェクトへのご参加ありがとうございます。まずはローカルでビルド・テストを行い、ドキュメントを参照しながら修正・機能追加に取り組んでください。質問や改善提案は Issue を通じてお気軽にお知らせください。これから一緒により良い教材環境を作っていきましょう！
