class Receipt < ApplicationRecord
  belongs_to :store
  has_many :receipt_details
end
