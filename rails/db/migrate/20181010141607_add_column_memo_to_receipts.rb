class AddColumnMemoToReceipts < ActiveRecord::Migration[5.0]
  def up
    add_column :receipts, :memo, :string, after: :updated_at
  end

  def down
    remove_column :receipts, :memo, :string
  end
end
