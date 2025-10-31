class AddFieldsToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :quantity, :float
    add_column :stocks, :purchase_price, :float
    add_column :stocks, :purchase_date, :string
  end
end
