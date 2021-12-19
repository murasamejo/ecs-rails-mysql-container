# Docker で Rails を実行する
- Rails アプリ
- MySQL

# 方法

## イメージを作る

```bash
# ビルドするために数分かかる
$ docker image build -t nikukyugamer/rails-on-ecs:0.0.1 .
$ docker image ls | grep nikukyu
nikukyugamer/rails-on-ecs                    0.0.1
           28170057ad42   8 minutes ago   1.12GB
```

## コンテナを作成する
- `-d` は `Run container in background` の意で、いわゆるデーモン化
- `-e` は環境変数設定
- `-h` は hostname 設定
- `-v` はボリューム設定
- `--name` はコンテナに名前をつける設定

```bash
$ docker container run -d -p 3000:3000 --name nikukyu nikukyugamer/rails-on-ecs:0.0.1
9cea37a5f5470747829889c86cbc04a22b74163d42ba0d8337cc3e69c458eba4
# Rails 単体起動だと Can't connect to local MySQL server through socket '/run/mysqld/mysqld.sock' (2) になれば OK
$ docker container ls
CONTAINER ID   IMAGE                             COMMAND                  CREATED
 STATUS         PORTS                    NAMES
c3318a487832   nikukyugamer/rails-on-ecs:0.0.1   "entrypoint.sh rails…"   11 seconds ago   Up 7 seconds   0.0.0.0:3000->3000/tcp   nikukyu
```

## コンテナの中に入る

```bash
$ docker container exec -it nikukyu /bin/bash
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

## コンテナを止める
```bash
$ docker container stop nikukyu
```

```bash
$ docker container ls
$ docker container ls -a
CONTAINER ID   IMAGE                             COMMAND                  CREATED
     STATUS                      PORTS     NAMES
c3318a487832   nikukyugamer/rails-on-ecs:0.0.1   "entrypoint.sh rails…"   About a minute ago   Exited (1) 10 seconds ago             nikukyu
```

# TODO
- Redis
