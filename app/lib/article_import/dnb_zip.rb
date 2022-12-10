# Article import for De Nieuw Band / Odin zipped XML
#
require 'zip'

module ArticleImport::DnbZip

  NAME = "Odin / Nieuwe Band (ZIP)"
  OUTLIST = true
  OPTIONS = {}.freeze

  def self.parse(file, opts={}, &block)
    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        next unless entry.name.end_with?('.xml')
        ArticleImport::DnbXml.parse(entry.get_input_stream, opts, &block)
      end
    end
  end

end
