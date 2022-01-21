class AddSaltToSuppliers < ActiveRecord::Migration[4.2]

  class Supplier < ActiveRecord::Base; end

  def up
    add_column :suppliers, :salt, :string

    Supplier.find_each do |supplier|
      salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
      supplier.update! salt: salt
    end

    change_column_null :suppliers, :salt, false
  end

  def down
    remove_column :suppliers, :salt
  end
end
