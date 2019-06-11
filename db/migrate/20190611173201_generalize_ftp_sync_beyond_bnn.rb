class GeneralizeFtpSyncBeyondBnn < ActiveRecord::Migration
  def change
    rename_column :suppliers, :bnn_sync, :ftp_sync
    rename_column :suppliers, :bnn_host, :ftp_host
    rename_column :suppliers, :bnn_user, :ftp_user
    rename_column :suppliers, :bnn_password, :ftp_password

    add_column :suppliers, :ftp_type, :integer, default: 0, null: false, after: :ftp_password
    add_column :suppliers, :ftp_regexp, :string, default: '^(\.\/)?PL', after: :ftp_type
  end
end
