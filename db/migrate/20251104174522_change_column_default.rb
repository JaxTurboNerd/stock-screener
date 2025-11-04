class ChangeColumnDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_null :stocks, :name, false
  end
end
