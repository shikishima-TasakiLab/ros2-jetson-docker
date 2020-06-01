# ROS2-Jetson-Docker

ROS2 dashing のJetson用Dockerイメージを作成する． また，コンテナ上でcatkin_make，ROSノードの起動を行えるようにする．

## インストール
```bash
#!/bin/bash
git clone https://github.com/shikishima-TasakiLab/ros2-jetson-docker.git ROS2-Jetson
```

## 使い方

### Dockerイメージの作成
次のコマンドでDockerイメージをビルドする．
```bash
#!/bin/bash
./ROS2-Jetson/docker/build-docker.sh
```
JetPackのバージョンにより，ベースイメージが自動選択される．

### Dockerコンテナの起動

1. 次のコマンドでDockerコンテナを起動する．
    
    ```bash
    #!/bin/bash
    ./ROS2-Jetson/docker/run-docker.sh
    ```

    |オプション          |パラメータ|説明                |既定値|例       |
    |-------------------|---------|--------------------|------|---------|
    |`-h`, `--help`     |なし     |ヘルプを表示        |なし  |`-h`     |
    |`-c`, `--container`|NAME     |コンテナの名前を指定|なし  |`-c ros2`|

1. 起動中のコンテナで複数のターミナルを使用する際は，次のコマンドを別のターミナルで実行する．

    ```bash
    #!/bin/bash
    ./ROS2-Jetson/docker/exec-docker.sh
    ```

    |オプション          |パラメータ|説明                |既定値|例       |
    |-------------------|---------|--------------------|------|---------|
    |`-h`, `--help`     |なし     |ヘルプを表示        |なし  |`-h`     |
