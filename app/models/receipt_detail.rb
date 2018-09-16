class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :expense, optional: true

=begin
  def expense
#    @expense ||= Expense.new
    Expense.new if self.expense.blank?
  end
=end
end
