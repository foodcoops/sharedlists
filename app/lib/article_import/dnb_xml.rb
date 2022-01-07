# Article import for De Nieuw Band XML file
#
# Always contains full assortment, including recently outlisted articles.
# To make sure we don't keep old articles when a number of updates was missed,
# +OUTLIST+ is set to +true+ to remove articles not present in the file.
#
require 'nokogiri'

module ArticleImport::DnbXml

  NAME = "De Nieuwe Band (XML)"
  OUTLIST = true
  OPTIONS = {}.freeze

  # parses a string or file
  def self.parse(file, opts={})
    doc = Nokogiri.XML(file, nil, nil,
      Nokogiri::XML::ParseOptions::RECOVER +
      Nokogiri::XML::ParseOptions::NONET +
      Nokogiri::XML::ParseOptions::COMPACT # do not modify doc!
    )
    doc.search('product').each do |row|
      # create a new article
      unit = row.search('eenheid').text
      unit = case(unit)
        when blank? then 'st'
        when 'stuk' then 'st'
        when 'g'    then 'gr' # need at least 2 chars
        when 'l'    then 'ltr'
        else             unit
      end
      inhoud = row.search('inhoud').text
      inhoud.blank? or (inhoud.to_f-1).abs > 1e-3 and unit = inhoud.gsub(/\.0+\s*$/,'') + unit
      deposit = row.search('statiegeld').text
      deposit.blank? and deposit = 0
      category = [
        @@codes[:indeling][row.search('indeling').text.to_i],
        @@codes[:indeling][row.search('subindeling').text.to_i]
      ].compact.join(' - ')

      article = {:number => row.search('bestelnummer').text,
                 #:ean => row.search('eancode').text,
                 :name => row.search('omschrijving').text,
                 :note => row.search('kwaliteit').text,
                 :manufacturer => row.search('merk').text,
                 :origin => row.search('herkomst').text,
                 :unit => unit,
                 :price => row.search('prijs inkoopprijs').text,
                 :unit_quantity => row.search('sve').text,
                 :tax => row.search('btw').text,
                 :deposit => deposit,
                 :category => category}

      yield article, (row.search('status') == 'Actief' ? :outlisted : nil)
    end
  end

  private

  @@codes = Hash.new

  def self.load_codes
    dir = Rails.root.join("app", "lib", "article_import")
    begin
      @@codes = YAML::load(File.open(dir.join("dnb_codes.yml"))).symbolize_keys
    rescue => e
      raise "Failed to load dnb_codes: #{dir}/dnb_codes.yml: #{e.message}"
    end
  end

end

ArticleImport::DnbXml.load_codes
