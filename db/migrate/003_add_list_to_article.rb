class AddListToArticle < ActiveRecord::Migration[4.2]
  def self.up
    add_column :articles, :list, :string
    add_column :suppliers, :lists, :string
  end

  def self.down
    remove_column :articles, :list
    remove_column :suppliers, :lists
  end
end
