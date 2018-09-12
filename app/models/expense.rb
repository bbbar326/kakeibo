class Expense < ApplicationRecord
  has_many :receipt_detail
end
