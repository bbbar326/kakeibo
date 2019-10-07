# kakeibo
自分用の家計簿アプリ

# 開発環境構築

1. dockerを入れる

2. git clone

```bash
$> git clone git@github.com:bbbar326/kakeibo.git
$> cd kakeibo
```

3. dockerホストで下記のコマンドを実行

```bash
$> docker-compose up -d
```

4. ログを確認し、pumaが起動したことを確認

```bash
$> docker-compose logs -f

# 下記のような文言が出たら完了
Bundle complete! 17 Gemfile dependencies, 68 gems now installed.
Bundled gems are installed into `./vendor/bundle`
```

5. DBの初期設定

```bash
$> docker exec -it ap bundle exec rails db:setup
```

6. アクセスして画面確認

```
http://localhost:3000
```

# DBのバックアップの撮り方(SQLite3の場合)

```bash
cd [cloneしたディレクトリ]

bin/rails db

# db一覧確認
.databases

# バックアップ
.backup main /data/db/backup/20190324_development.sqlite3

# リストア
.restore main /data/db/backup/20190324_development.sqlite3

# dumpファイルを取得したい場合
.output /data/db/backup/20190123_development.dump.txt
.dump

```

# ansible実行

1. 事前準備

```bash
#----------------------------
# git cloneしたディレクトリに移動
#----------------------------
$ cd ../
$ pwd
#=> C:\@dev\src

#----------------------------
# ansible-controllerをgit clone
#----------------------------
$ git clone https://github.com/bbbar326/ansible-controller.git

#----------------------------
# ansible-controller起動
#----------------------------
$ cd ./ansible-controller
$ pwd
#=> C:\@dev\src\ansible-controller
$ docker-compose up -d
```

2. ansible実行

```bash
#----------------------------
# kakeiboのルートディレクトリに移動
#----------------------------
$ cd ../kakeibo
$ pwd
#=> C:\@dev\src\kakeibo

#----------------------------
# playbook実行
#----------------------------
# power shellの場合
$ ./bin/run_playbook.ps1
```