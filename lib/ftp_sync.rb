require 'net/ftp'
require 'fileutils'

module FtpSync

  # compares remote with local filelist
  # if local file not exists or older than remote file, download remote file
  # return array with new files
  def self.sync(supplier)
    new_files = Array.new

    # change local dir to save files correctly
    FileUtils.mkdir_p(supplier.ftp_path) unless File.exists?(supplier.ftp_path)
    Dir.chdir(supplier.ftp_path)

    # connect to ftp-server
    ftp = Net::FTP.new(supplier.ftp_host, supplier.ftp_user, supplier.ftp_password)

    # loop over the remote filelist
    ftp.nlst.each do |filename|
      if filename.match(Regexp.new(supplier.ftp_regexp))
        # local file not exist or remote file newer ?
        if (File.exist?(filename) and File.new(filename).mtime < ftp.mtime(filename)) or !File.exist?(filename)
          # download
          ftp.getbinaryfile(filename)
          # save filename for return
          new_files << filename
        end
      end
    end
    # close ftp-session
    ftp.close
    return new_files
  end

end
