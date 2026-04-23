class AddTickerToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :ticker, :string
  end
end
