class AddMailSyncToSupplier < ActiveRecord::Migration[4.2]
  def change
    add_column :suppliers, :mail_sync, :boolean
    add_column :suppliers, :mail_from, :string
    add_column :suppliers, :mail_subject, :string
    add_column :suppliers, :mail_type, :string
  end
end
