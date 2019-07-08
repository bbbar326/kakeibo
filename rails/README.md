# kakeibo
自分用の家計簿アプリ

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
