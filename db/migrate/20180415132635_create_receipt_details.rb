class CreateReceiptDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :receipt_details do |t|
      t.integer :expense_id
      t.integer :price
      t.string :name

      t.timestamps
    end
  end
end
