require 'csv'

class Receipt < ApplicationRecord
  belongs_to :store
  belongs_to :pay_account, optional: true
  has_many :receipt_details, dependent: :delete_all
  accepts_nested_attributes_for :receipt_details
  attr_accessor :store_name

  scope :search, lambda { |search_word| where("date LIKE ?", "%#{search_word}%") }

  class CsvFormat
    def initialize
      create_xxxx_headar
    end

    # xxxx_headerでダウンロード時のヘッダー名を返す
    # 例：
    # reciept_header
    # => ["id", "name"]
    def create_xxxx_headar
      arr = HEADER.group_by {|e| e.split("/")[0]}
      arr.each do |table_name, column_name|
        CsvFormat.class_eval do
          define_method "#{table_name}_header" do
            column_name.map { |e| e.split("/")[1] }
          end
        end
      end

=begin
      arr = HEADER.group_by {|e| e.split("/")[0]}
      arr = arr.map do |e| 
        {
          table_name: e[0],
          column_name: e[1].map {|m| m.split("/")[1]},
        }
      end
      puts arr
=end

#      arr = HEADER.map { |e| e.split("/") }
#      arr = arr.group_by {|e| e[0]}
#      puts arr.inspect


#      HEADER.each do |e|
#        el = e.split("/") 
#        table_name = el[0]
#        column_name = el[1]
#      end
    end

    HEADER = 
      [
        "receipt/id",
        "store/name",
        "store/tel",
        "pay_account/name",
      ].freeze
  end

  def self.to_csv
    bom = %w(EF BB BF).map { |e| e.hex.chr }.join
    CSV.generate(bom) do |csv|

      formatter = CsvFormat.new

      receipt_header = formatter.receipt_header
      store_header = formatter.store_header
      pay_account_header = formatter.pay_account_header

      # column_namesはカラム名を配列で返す
      # 例: ["id", "name", "price", "released_on", ...]
      h =  receipt_header.map{|e| "receipt/#{e}"}
      h += store_header.map{|e| "store/#{e}"}
      h += pay_account_header.map{|e| "pay_account/#{e}"}

      csv << h

      all.preload(:store, :pay_account).each do |e|
        # attributes はカラム名と値のハッシュを返す
        # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
        # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
        # 下の行は最終的に column_namesで指定したvalue値の配列を返す
        # 「*」を付与することによって配列を出力した状態で返す
        v =  e.attributes.values_at(*receipt_header)
        v += e.store.attributes.values_at(*store_header) if e.store
        v += e.pay_account.attributes.values_at(*pay_account_header) if e.pay_account

        csv << v
      end
    end
  end

  def self.from_csv(file)
    count = 0
    logger.info "-----------CSVの読み込み_開始-----------"
    CSV.foreach(file.path, headers: true) do |fg|
      puts fg.inspect
      logger.info fg

=begin
      record = self.find_or_initialize_by(id: fg["id"])
      record.attributes = fg.to_hash.slice(*updatable_attributes)

      record.save
      count += 1
=end
    end
    logger.info "-----------CSVの読み込み_終了-----------"
    count
  end

  def self.from_xml(file)

    count = 0
    doc = REXML::Document.new(file.read)

    doc.elements.each('receipt_data/receipt_list/receipt') do |receipt|

      next unless receipt

      # 参考情報としてreceipt_idをmemoに登録しておく
      memo = "receipt_id: " + receipt.elements['receipt_id']&.text

      store_name = receipt.elements['store']&.text
      store_tel = receipt.elements['tel']&.text
      date = receipt.elements['date']&.text

      date = nil unless date_valid?(date)

      # --------------------------------------------------------------------------------
      # 電文解析
      # --------------------------------------------------------------------------------

      # 店舗
      # nameとtelで検索してすでに存在していればその値を取得
      store = Store.find_or_initialize_by(name: store_name, tel: store_tel)

      # 明細
      receipt_details = []

      receipt.elements.each('item_list/item') do |receipt_detail|
        receipt_detail_price = receipt_detail.elements['price']&.text&.to_i
        receipt_detail_name = receipt_detail.elements['name']&.text
        receipt_details << {price: receipt_detail_price, name: receipt_detail_name}
      end
      
      # バリデーション
      next if validate(date, store_tel, store_name, receipt_details)
      
      # 登録
      self.transaction do
        new_receipt = Receipt.create(date: date, store: store, memo: memo)
        new_receipt.receipt_details.create(receipt_details)
        count += 1
      end
    end

    count
  end

  private

  def self.date_valid?(str)
    !! Date.parse(str) rescue false
  end

  # --------------------------------------------------------------------------------
  # バリデーション
  # ・日付、店舗の電話番号、合計金額が一致してるレコードを取得。
  # ・一致してたレコードのうち、明細も全て同じの場合は登録済みとしてスキップ。
  # ・[TODO]明細が違う場合は、登録は実行しておいて警告を出す。
  # --------------------------------------------------------------------------------
  def self.validate(date, store_tel, store_name, receipt_details)

    hits = Receipt.joins(:store, :receipt_details).where(date: date, stores: {tel: store_tel, name: store_name})
    isExistReceipt = false

    if hits.present?
      # 日付、店舗の電話番号が一致しているレコードある場合
      total = receipt_details.sum { |h| h[:price]}

      hits.each do |hit|
        isMatchPrice = false
        isMatchDetail = false
        # 金額を確認
        if hit.receipt_details.sum(:price) == total
          isMatchPrice = true
        end

        # 金額が合致している場合は明細を確認
        if isMatchPrice
          isMatchDetail = true
          hit.receipt_details.each_with_index do |hit_receipt_detail, i|
            if receipt_details[i][:name] != hit_receipt_detail.name
              isMatchDetail = false
              break
            end
          end
        end

        # 金額と明細が一致したレコードは無視する
        if isMatchPrice && isMatchDetail
          isExistReceipt = true
          break
        end
      end
    end

    isExistReceipt
  end

  def self.updatable_attributes
    ["date", "store_id", "pay_account_id"]
  end

end
