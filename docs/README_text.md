# IT未来塾教科書
講義で使う教科書・スライドをビルドします。

## ビルド手順 (Docker)
### Prerequisites
本リポジトリを適当な場所に `git clone` する。

[Docker Engine (または Docker Desktop)](https://docs.docker.com/engine/install/) をインストールする。

タイプセットのための Docker Image をプル（ダウンロード）する。

```
docker pull ghcr.io/omesatofoundation/ome-doc/texlive:latest
```

latest ではないバージョンを使用する必要があれば，https://github.com/OmeSatoFoundation/ome-doc/pkgs/container/ome-doc%2Ftexlive から必要なバージョンを選択し，tag として latest を置き換えて pull する．

(optional) このあとの手順に合うように、イメージ名を短いものに変更する。

```
docker tag ghcr.io/omesatofoundation/ome-doc/texlive:latest latex
```

https://github.com/OmeSatoFoundation/ome-doc/pkgs/container/ome-doc%2Ftexlive

プルができない場合、または必要がある場合はタイプセットのための Docker Image をローカルコンピュータでビルドすることもできる。

```
# タイプセットのための Docker Image をビルドする。 1GB のストレージ使用と 1 時間程度の時間がかかる。
# このリポジトリの clone 先に作業ディレクトリを移動して、以下のコマンドを実行する。
docker build . -f docker/text.Dockerfile -t latex --target buildenv
```

### 全章ビルドして book を作る
TBD

### チャプター単体をビルドする
`llmk.toml` があるディレクトリで `llmk` を実行する．ただし、コンテナにはプロジェクトルートを bind-mount する必要がある。
例: 教科書 3 章 `03/textbook/text03.tex`をタイプセットする:

```
# プロジェクトルート (clone 先のディレクトリ) で以下のコマンドを実行する。
docker run --rm -v ${PWD}:/workdir --workdir=/workdir/03/textbook latex llmk
```

中間ファイルを消去する

```
docker run --rm -v ${PWD}:/workdir --workdir=/workdir/03/textbook latex llmk -c
```

その他 llmk の詳しい使い方: https://ftp.yz.yamagata-u.ac.jp/pub/CTAN/support/light-latex-make/llmk.pdf


### チャプターの一部をビルドする
チャプター全体を含むファイル (e.g., `text03.tex`) の他に，チャプターが読み込む個ファイルを単体でビルドすることもできる．
例: 教科書 3 章の `chap03_010_Intro.tex` をビルドする

```
# プロジェクトルート (clone 先のディレクトリ) で以下のコマンドを実行する。
docker run --rm -v ${PWD}:/workdir --workdir=/workdir/03/textbook latex llmk -i contents/chap03_010_Intro.tex
```

この機能は [`subfiles` パッケージ](https://ctan.org/pkg/subfiles)と [llmk のフォーク](https://github.com/RollMan/llmk/tree/clarg_overwriting_config)で実現している．

## ビルド手順 (Docker, experimental)
### Prerequisites
[上記ビルド手順](#ビルド手順 (docker))
と同じ。

### 全章ビルドして book を作る
TBD

### チャプター単体をビルドする
例: 教科書 3 章をビルドする

```bash
# プロジェクトルート (clone 先のディレクトリ) で以下のコマンドを実行する。
TARGET=03/textbook
docker build . -f docker/text.Dockerfile --output "${TARGET}/" --build-arg TARGET="${TARGET}"
```

`03/textbook` に目的のファイルが生成される。

Note that `--output` must be `${TARGET}` otherwise latex cannot find intermediate files like `.aux`, and it slows typeset time.

### エラーが出るとき・texlive を自分でビルドしたいとき

何らかの理由でリモートコンテナレジストリからベースイメージを取得するのに失敗して以下のようなメッセージが現れた場合，

```
ERROR: failed to build: failed to solve: ghcr.io/omesatofoundation/ome-doc/ome-doc:latest: failed to resolve source metadata for ghcr.io/omesatofoundation/ome-doc/typsetenv:latest: ghcr.io/omesatofoundation/ome-doc/ome-doc:latest: not found
```

または，texlive をローカル環境でビルドしたい場合は，`docker build` コマンドにオプション

```
--build-arg BASE_IMAGE=buildenv
```

を追加して実行する．例:

```bash
docker build . -f docker/text.Dockerfile --output . --build-arg TARGET="." --build-arg BASE_IMAGE=buildenv
```

### GitHub Container Registry への push
texlive を含む、教科書・スライドをビルドする環境は GitHub Workflow 経由で push され、GitHub Container Registry 経由で管理されます。
詳細は `/home/yshimmyo/Documents/ome-doc/.github/workflows/build-image.yml` を確認してください。

- Working with the Container registry - GitHub Docs https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
- GitHub Actions documentation - GitHub Docs https://docs.github.com/en/actions

## ビルド手順 (Windows, Linux, Mac)
### Prerequisites
- TeXLive をインストールする (full scheme を選択する)
    - windows https://www.tug.org/texlive/windows.html
    - linux https://www.tug.org/texlive/quickinstall.html
    - mac https://www.tug.org/mactex/
- 依存パッケージをインストールする
    - 最新に必要なパッケージは  [Dockerfile:49 あたり](https://github.com/OmeSatoFoundation/ome-doc/blob/master/Dockerfile#L49) を参照。

```
$ tlmgr install bbding # libreoffice ソースから latex ソースへの自動変換を利用した際に必要。その他必要なパッケージは [Dockerfile:49 あたり](https://github.com/OmeSatoFoundation/ome-doc/blob/master/Dockerfile#L49) を参照。
```

- `llmk` をインストールする

```
$ tlmgr install light-latex-mk
```

### 全章ビルドして book を作る
TBD

### チャプター単体をビルドする
CMD、Powershell、bash 等からチャプターディレクトリ (`01/`, `02/`, and so on) で `llmk` コマンドを発行。

```
cd 01/
llmk
```
