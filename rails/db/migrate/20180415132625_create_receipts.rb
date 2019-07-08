class CreateReceipts < ActiveRecord::Migration[5.0]
  def change
    create_table :receipts do |t|
      t.date :date
      t.integer :store_id

      t.timestamps
    end
  end
end
