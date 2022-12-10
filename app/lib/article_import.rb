require 'digest/sha1'
require 'tempfile'

module ArticleImport

  class ConversionFailedException < Exception; end

  # return list of known file formats
  #   each file_format module has
  #   #name              return a human-readable file format name
  #   #outlist_unlisted  if returns true, unlisted articles are outlisted
  #   #detect            return a likelyhood (0-1) of being able to process
  #   #parse             parse the data
  #
  def self.file_formats
    @@file_formats ||= {
      'bnn' => ArticleImport::Bnn,
      'borkenstein' => ArticleImport::Borkenstein,
      'foodsoft' => ArticleImport::Foodsoft,
      'dnb_xml' => ArticleImport::DnbXml,
      'dnb_zip' => ArticleImport::DnbZip,
      'bioromeo' => ArticleImport::Bioromeo,
    }.freeze
  end

  # Parse file by type (one of {.file_formats})
  #
  # @param file [File, Tempfile]
  # @option opts [String] type file format (required) (see {.file_formats})
  # @return [File, Roo::Spreadsheet] file with encoding set if needed
  def self.parse(file, type:, **opts, &blk)
    # @todo handle wrong or undetected type
    parser = file_formats[type]
    if block_given?
      parser.parse(file, **opts, &blk)
    else
      data = []
      parser.parse(file, **opts) { |a| data << a }
      data
    end
  end


  # Helper method to generate an article number for suppliers that do not have one
  def self.generate_number(article)
    # something unique, but not too unique
    s = "#{article[:name]}-#{article[:unit_quantity]}x#{article[:unit]}"
    s = s.downcase.gsub(/[^a-z0-9.]/,'')
    # prefix abbreviated sha1-hash with colon to indicate that it's a generated number
    article[:number] = ':' + Digest::SHA1.hexdigest(s)[-7..-1]
    article
  end

  # Helper method for opening a spreadsheet file
  #
  # @param file [File] file to open
  # @param filename [String, NilClass] optional filename for guessing the file format
  # @param encoding [String, NilClass] optional CSV encoding
  # @param col_sep [String, NilClass] optional column separator
  # @return [Roo::Spreadsheet]
  def self.open_spreadsheet(file, filename: nil, encoding: nil, col_sep: nil)
    opts = {csv_options: {}}
    opts[:csv_options][:encoding] = encoding if encoding
    opts[:csv_options][:col_sep] = col_sep if col_sep
    opts[:extension] = File.extname(filename) if filename
    Roo::Spreadsheet.open(file, **opts)
  end
end
