class AddReceiptIdToReceiptDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :receipt_details, :receipt_id, :integer
  end
end
