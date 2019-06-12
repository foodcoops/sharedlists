class ReviseFtpFieldsInSuppliers < ActiveRecord::Migration
  def up
    change_column :suppliers, :ftp_type, :string, default: 'bnn', null: true
    change_column_default :suppliers, :ftp_regexp, '^([.]/)?PL'
  end

  def down
    change_column :suppliers, :ftp_type, :integer, default: 0
    change_column_default :suppliers, :ftp_regexp, '^(\.\/)?PL'
  end
end
