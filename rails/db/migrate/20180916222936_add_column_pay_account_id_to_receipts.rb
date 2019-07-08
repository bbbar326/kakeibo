class AddColumnPayAccountIdToReceipts < ActiveRecord::Migration[5.0]
  def up
    add_column :receipts, :pay_account_id, :integer, after: :store_id
  end

  def down
    remove_column :receipts, :pay_account_id, :integer
  end
end
