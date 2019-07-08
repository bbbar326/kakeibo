class CreatePayAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :pay_accounts do |t|
      t.string :name

      t.timestamps
    end
  end
end
