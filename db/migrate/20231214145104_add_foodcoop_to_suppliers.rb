class AddFoodcoopToSuppliers < ActiveRecord::Migration[7.1]
  def change
    add_column :suppliers, :foodcoop, :string
  end
end
  