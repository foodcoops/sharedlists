desc "Sync files via FTP. Update articles."
task :sync_ftp_files => :environment do
  Supplier.ftp_sync.all.each do |supplier|
    puts "FTP-sync files for #{supplier.name}..."
    supplier.sync_ftp_files
  end
end
