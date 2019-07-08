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

rails db

# db一覧確認
.databases

# バックアップ
.backup main c:\\data6\\kakeibo\\db\\backup\\20190123_development.sqlite3

# dumpファイルを取得したい場合
.output c:\\data6\\kakeibo\\db\\backup\\20190123_development.dump.txt
.dump
```
