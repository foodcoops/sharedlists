class RemoveArticleListsFromSuppliers < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :suppliers, :lists
    remove_column :articles, :list
  end

  def self.down
    add_column :articles, :list, :string
    add_column :suppliers, :lists, :string
  end
end
