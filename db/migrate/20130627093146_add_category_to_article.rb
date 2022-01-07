class AddCategoryToArticle < ActiveRecord::Migration[4.2]
  def self.up
    add_column :articles, :category, :string
  end

  def self.down
    remove_column :articles, :category
  end
end
