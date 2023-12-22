class AddFoodcoopToSuppliers < ActiveRecord::Migration[7.1]
  def up
    add_column :suppliers, :foodcoop, :string, :null => false, :default => ''
  end

  def down
    remove_column :suppliers, :foodcoop
  end
end
  