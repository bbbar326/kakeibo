require 'csv'

class Receipt < ApplicationRecord
  belongs_to :store
  belongs_to :pay_account, optional: true
  has_many :receipt_details, dependent: :delete_all
  accepts_nested_attributes_for :receipt_details

  scope :search, lambda { |search_word| where("date LIKE ?", "%#{search_word}%") }

  def self.to_csv
    CSV.generate do |csv|
      # column_namesはカラム名を配列で返す
      # 例: ["id", "name", "price", "released_on", ...]
      csv << column_names
      all.each do |column|
        # attributes はカラム名と値のハッシュを返す
        # 例: {"id"=>1, "name"=>"レコーダー", "price"=>3000, ... }
        # valudes_at はハッシュから引数で指定したキーに対応する値を取り出し、配列にして返す
        # 下の行は最終的に column_namesで指定したvalue値の配列を返す
        csv << column.attributes.values_at(*column_names)
      end
    end
  end

  def self.from_csv(file)
    count = 0
    CSV.foreach(file.path, headers: true) do |fg|
      record = self.find_or_initialize_by(id: fg["id"])
      record.attributes = fg.to_hash.slice(*updatable_attributes)

      record.save
      count += 1
    end
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
