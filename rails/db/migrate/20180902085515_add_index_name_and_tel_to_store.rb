class AddIndexNameAndTelToStore < ActiveRecord::Migration[5.0]
  def change
    add_index :stores, [:name, :tel], :unique => true
  end
end
