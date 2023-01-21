class ChangeScaleQuantity < ActiveRecord::Migration[6.1]
  def change
    change_column :articles, :scale_quantity, :decimal, precision: 8, scale: 2
  end
end
