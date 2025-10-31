class AddNameToStock < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :name, :string
  end
end
