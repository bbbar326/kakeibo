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
end
