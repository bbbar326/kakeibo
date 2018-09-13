class Receipt < ApplicationRecord
  belongs_to :store
  has_many :receipt_details, dependent: :delete_all
  accepts_nested_attributes_for :receipt_details
end
