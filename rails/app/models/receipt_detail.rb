class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :expense, optional: true

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

  def self.updatable_attributes
    ["expense_id", "price", "name"]
  end
end
