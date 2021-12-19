# Docker で Rails を実行する
- Rails アプリ
- MySQL
- Redis

# 注意点
- `localhost` は使えない
  - [Dockerで立ち上げたmysqldに接続する | ハックノート](https://hacknote.jp/archives/30781/)
- `volume` オプションにおいて、ホスト側では相対パスを使えない
  - Docker Compose だとそこを内部でよしなにやってくれている？
- MySQL のユーザー名は不要だがパスワードは明示的に指定する必要がある
  - MySQL および Rails のコンテナを作る時に環境変数で指定する

# 方法

## ネットワークの作成 ($ docker network create)
- 作成したネットワーク名を、今後の `$ docker container run` コマンドの中でオプションで指定する

```bash
$ docker network create nikukyu-network
5f61157b37fdac07fd07fc9dd40669b603a71ccc6ee1e1062cac3207673b2592
$ docker network list
NETWORK ID     NAME                              DRIVER    SCOPE
5f61157b37fd   nikukyu-network                   bridge    local
```

## Rails アプリ

### イメージを作る ($ docker image build)

```bash
# ビルドするために数分かかる
$ docker image build -t nikukyugamer/rails-on-ecs:0.0.1 .
$ docker image ls | grep nikukyu
nikukyugamer/rails-on-ecs                    0.0.1
           28170057ad42   8 minutes ago   1.12GB
```

### コンテナを作成する ($ docker container run)
- `-d` は `Run container in background` の意で、いわゆるデーモン化
- `-e` は環境変数設定
- `-h` は hostname 設定
- `-v` はボリューム設定
- `--name` はコンテナに名前をつける設定
- `--rm` は `Automatically remove the container when it exits` する

```bash
$ docker container run -d -p 3000:3000 --name nikukyu-rails --network nikukyu-network -e MYSQL_HOST=nikukyu-mysql-host -e MYSQL_PASSWORD=my-secret-pw nikukyugamer/rails-on-ecs:0.0.1
9cea37a5f5470747829889c86cbc04a22b74163d42ba0d8337cc3e69c458eba4
# Rails 単体起動だと Can't connect to local MySQL server through socket '/run/mysqld/mysqld.sock' (2) になれば OK
$ docker container ls
CONTAINER ID   IMAGE                             COMMAND                  CREATED
 STATUS         PORTS                    NAMES
c3318a487832   nikukyugamer/rails-on-ecs:0.0.1   "entrypoint.sh rails…"   11 seconds ago   Up 7 seconds   0.0.0.0:3000->3000/tcp   nikukyu-rails
```

### コンテナの中に入る ($ docker container exec)

```bash
$ docker container exec -it nikukyu-rails /bin/bash
root@c3318a487832:/myapp#
```

```
$ docker container exec --help
Options:
  -d, --detach               Detached mode: run command in the background
      --detach-keys string   Override the key sequence for detaching a container
  -e, --env list             Set environment variables
      --env-file list        Read in a file of environment variables
  -i, --interactive          Keep STDIN open even if not attached
      --privileged           Give extended privileges to the command
  -t, --tty                  Allocate a pseudo-TTY
  -u, --user string          Username or UID (format: <name|uid>[:<group|gid>])
  -w, --workdir string       Working directory inside the container
```

### コンテナを止める ($ docker container stop)
```bash
$ docker container stop nikukyu-rails
```

```bash
$ docker container ls
$ docker container ls -a
CONTAINER ID   IMAGE                             COMMAND                  CREATED
     STATUS                      PORTS     NAMES
c3318a487832   nikukyugamer/rails-on-ecs:0.0.1   "entrypoint.sh rails…"   About a minute ago   Exited (1) 10 seconds ago             nikukyu-rails
```

## MySQL
- https://hub.docker.com/_/mysql/
  - 予約語になっている環境変数について記述がある
    - Qiita に記事もある
      - [DockerのMySQLイメージ起動時に渡す環境変数 - Qiita](https://qiita.com/nanakenashi/items/180941699dc7ba9d0922)
- MySQL 8 だと認証問題があるので、独自の設定ファイルを組み込んだイメージをビルドする必要があるかもしれない
  - [Dockerネットワークを設定してコンテナ間通信する【RailsとMySQL】 | キツネの惑星](https://kitsune.blog/docker-network)
- `$ docker run --name some-mysql -v /my/own/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag` が基本コマンド
  - `--hostname` で命名した名前がホスト名になり、Rails の `database.yml` 内の `host` でそのまま名前として指定できる

```bash
# $ docker container run --name nikukyu-mysql --network nikukyu-network -v /tmp/nikukyu_mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:8.0.27
$ docker container run --name nikukyu-mysql --hostname nikukyu-mysql-host --network nikukyu-network -v /tmp/nikukyu_mysql_data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7.36
```

## MySQL が立ち上がっている状態で db:create db:migrate を行う
- （参考）一般的なコマンド実行例

```bash
$ docker container exec nikukyu-rails bin/rails -v
Rails 7.0.0
```

- db:create db:migrate を行う

```bash
$ docker container exec nikukyu-rails bin/rails db:create
$ docker container exec nikukyu-rails bin/rails db:migrate
```
