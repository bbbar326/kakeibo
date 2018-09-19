class Receipt < ApplicationRecord
  belongs_to :store
  belongs_to :pay_account, optional: true
  has_many :receipt_details, dependent: :delete_all
  accepts_nested_attributes_for :receipt_details

  scope :search, lambda { |search_word| where("date LIKE ?", "%#{search_word}%") }
end
