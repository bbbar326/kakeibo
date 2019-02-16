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

    # [テーブル名]_headerでヘッダー名を返す
    # 例：
    # reciept_header
    # => ["id", "name"]
    # receipt_HEADER
    # => ["receipt/id", "receipt/name"]
    def create_xxxx_headar
      arr = HEADER.group_by {|e| e.split("/")[0]}
      arr.each do |table_name, column_name|
        CsvFormat.class_eval do
          define_method "#{table_name}_header" do
            column_name.map { |e| e.split("/")[1] }
          end
          define_method "#{table_name}_HEADER" do
            column_name.map{|e| e}
          end
        end
      end
    end

    # receipt_attributes(csv)で、テーブルに存在するキーのみのhashを作る
    # 例：
    # reciept_attributes({"receipt/id" => "hoge", "fuga/name" => "fuga"})
    # => {id: "hoge"}
    def receipt_attributes(fg)
      h = fg.to_hash.select {|e| receipt_HEADER.include?(e)}
      result = {}

      h.each do |k, v|
        result.merge({k.split("/")[1] => v})
      end

      result
    end

    HEADER = 
      [
        "receipt/id",
        "receipt/date",
        "store/name",
        "store/tel",
        "pay_account/name",
        "receipt_detail/price",
        "receipt_detail/expense",
        "receipt_detail/name",
      ].freeze
  end

  def self.to_csv
    bom = %w(EF BB BF).map { |e| e.hex.chr }.join
    CSV.generate(bom) do |csv|

      formatter = CsvFormat.new

      receipt_header = formatter.receipt_header
      store_header = formatter.store_header
      pay_account_header = formatter.pay_account_header
      receipt_detail_header = formatter.receipt_detail_header

      # column_namesはカラム名を配列で返す
      # 例: ["id", "name", "price", "released_on", ...]
      h = CsvFormat::HEADER

      csv << h

      all.preload(:store, :pay_account, :receipt_details).each do |e|
        # attributes はカラム名と値のハッシュを返す
        # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
        # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
        # 下の行は最終的に column_namesで指定したvalue値の配列を返す
        # 「*」を付与することによって配列を出力した状態で返す
        v1 =  e.attributes.values_at(*receipt_header)
        v2 = e.store ? e.store.attributes.values_at(*store_header) : ""
        v3 = e.pay_account ? e.pay_account.attributes.values_at(*pay_account_header) : ""
        if e.receipt_details
          v4 = e.receipt_details.sum(:price)

          expense_ids = e.receipt_details.distinct.pluck(:expense_id)
          expense_names = Expense.where(id: expense_ids).map{|e| e.name}
          v5 = expense_names.join(", ")
          v6 = e.receipt_details.map{|e| e.name}.join(", ")
        else
          v4 = ""
          v5 = ""
          v6 = ""
        end
        
        csv << [*v1, *v2, *v3, v4, v5, v6]
      end
    end
  end

  def self.from_csv(file)
    @stores = Store.all.map{|e| [e[:id], e[:name]]}
    @pay_accounts = PayAccount.all.map{|e| [e[:id], e[:name]]}
#    @expenses = Expenses.all.map{|e| [e[:id], e[:name]]}

    formatter = CsvFormat.new

    count = 0
    logger.info "-----------CSVの読み込み_開始-----------"
    CSV.foreach(file.path, headers: true, encoding: 'BOM|UTF-8') do |fg|

      record = preload(:store, :pay_account).find_or_initialize_by(id: fg["receipt/id"])

      update_attributes = formatter.receipt_attributes(fg)

      store_id = ""
      pay_account_id = ""
      expense_id = ""

      # store_idをstore/nameから引き当てる
      if fg["store/name"] && fg["store/name"] != record.store&.name
        store_id = @stores.find(->{[nil, nil]}) {|id, name| fg["store/name"] == name}[0]
        update_attributes.merge!({"store_id" => store_id})
      end

      # pay_account_idをpay_account/nameから引き当てる
      if fg["pay_account/name"] && fg["pay_account/name"] != record.pay_account&.name
        pay_account_id = @pay_accounts.find(->{[nil, nil]}){|id, name| fg["pay_account/name"] == name}[0]
        update_attributes.merge!({"pay_account_id" => pay_account_id})
      end

=begin
      # expense_idをreceipt_detail/expense(name)から引き当てる
      if fg["receipt_detail/expense"] && fg["receipt_detail/expense"]
        expense_id = @expenses.find(->{[nil, nil]}){|id, name| fg["receipt_detail/expense"] == name}[0]
        update_attributes.merge!({"receipt_details" => {"expense_id" => expense_id})
      end
=end

      # 違いがあるレコードのみ更新する

      new_attr      = update_attributes.slice(*updatable_attributes)
      original_attr = record.attributes.slice(*(new_attr.keys))

      if original_attr != new_attr
        logger.info "★現在：#{original_attr}"
        logger.info "★更新：#{new_attr}"

        record.attributes = new_attr
        record.save
        count += 1
      end
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
#    ["date", "store_id", "pay_account_id"]
    ["date", "pay_account_id"]
  end

end
