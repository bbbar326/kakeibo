# CSVでShift_JIS読むときに環境依存文字があると落ちるため、
# undef+replace（定義に存在しないときに置換する）をCSV.foreachでも
# オプション指定することが出来るようにするモンキーパッチ。
# 
# undef+replaceは元々File.openの引数。File.openした後に、オプションをそのままCSVの
# initializerに渡している。initializerではCSVと関係するオプションを処理していって、
# 最後にCSVと直接関係しないオプションが一つでも設定されていれば例外を出す作りになっている。
# そのため、File.openで設定可能なオプションでもCSVで例外となっている。
# 
# このモンキーパッチでは、File.open後、CSVのインスタンス生成前に、予めundefとreplaceオプションを
# 削除してからinitializerの処理を行うようにする。
#
# 参考
# https://qiita.com/yuuna/items/7e4e06a1b881d85697e9

require "csv"

module CSVEncodingExtension
  def initialize(data, options = Hash.new)
    options.delete(:replace)
    options.delete(:undef)
    super
  end
end

CSV.send(:prepend, CSVEncodingExtension)
