class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :expense, optional: true
end
