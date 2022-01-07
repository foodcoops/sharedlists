# -*- coding: utf-8 -*-
# Module for Foodsoft-file import
# The Foodsoft-file is a CSV-file, with semicolon-separated columns, or ODS/XLS/XLSX

require 'roo'
require 'roo-xls'

module ArticleImport::Foodsoft

  NAME = "Foodsoft (CSV, ODS, XLS, XLSX)"
  OUTLIST = false
  OPTIONS = {
    encoding: "UTF-8",
    col_sep: ";"
  }.freeze

  # Parses Foodsoft file
  # the yielded article is a simple hash
  def self.parse(file, **opts)
    opts = OPTIONS.merge(opts)
    ss = ArticleImport.open_spreadsheet(file, **opts)

    header_row = true
    ss.sheet(0).each do |row|
      # skip first header row
      if header_row
        header_row = false
        next
      end
      # skip empty lines
      next if row[2].blank?

      article = {:number => row[1],
                 :name => row[2],
                 :note => row[3],
                 :manufacturer => row[4],
                 :origin => row[5],
                 :unit => row[6],
                 :price => row[7],
                 :tax => row[8],
                 :unit_quantity => row[10],
                 :scale_quantity => row[11],
                 :scale_price => row[12],
                 :category => row[13]}
      article.merge!(:deposit => row[9]) unless row[9].nil?
      article[:number].blank? and ArticleImport.generate_number(article)
      if row[6].nil? || row[7].nil? or row[8].nil?
        yield article, "Error: unit, price and tax must be entered"
      else
        yield article, (row[0]=='x' ? :outlisted : nil)
      end
    end
  end

end
