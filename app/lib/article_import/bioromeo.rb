# Module for import of BioRomeo products from their Excel sheet, from Aug 2014 onwards

require 'roo'
require 'roo-xls'

module ArticleImport::Bioromeo

  NAME = "BioRomeo (XLSX, XLS, CSV)"
  OUTLIST = true
  OPTIONS = {
    encoding: "UTF-8",
    col_sep: ";"
  }.freeze

  RE_UNITS = /(kg|gr|gram|pond|st|stuks?|set|bos|bossen|bosjes?|bak|bakjes?|liter|ltr|[lL]\.|ml|bol|krop)(\s*\.)?/i
  RES_PARSE_UNIT_LIST = [
    /\b((per|a)\s*)?([0-9,.]+\s*x\s*[0-9,.]+\s*#{RE_UNITS})/i,                     # 1x5 kg
    /\b((per|a)\s*)?([0-9,.]+\s*#{RE_UNITS}\s+x\s*[0-9,.]+)/i,                     # 1kg x 5
    /\b((per|a)\s*)?(([0-9,.]+\s*,\s+)*[0-9,.]+\s+of\s+[0-9,.]+\s*#{RE_UNITS})/i,  # 1, 2 of 5 kg
    /\b((per|a)\s*)?([0-9,.]+\s*#{RE_UNITS})/i,                                    # 1kg
    /\b((per|a)\s*)?(#{RE_UNITS})/i                                                # kg
  ]
  # first parse with dash separator at the end, fallback to less specific
  RES_PARSE_UNIT = RES_PARSE_UNIT_LIST.map {|r| /-\s*#{r}\s*$/} +
                   RES_PARSE_UNIT_LIST.map {|r| /-\s+#{r}/} +
                   RES_PARSE_UNIT_LIST.map {|r| /#{r}\s*$/} +
                   RES_PARSE_UNIT_LIST.map {|r| /-#{r}/}

  def self.parse(file, **opts)
    opts = OPTIONS.merge(opts)
    ss = ArticleImport.open_spreadsheet(file, **opts)

    header_row = true
    sheet = ss.sheet(0).parse(clean: true,
      number:     /^artnr/i,
      name:       /^product/i,
      skal:       /^skal$/i,
      demeter:    /^demeter$/i,
      unit_price: /prijs\b.*\beenh/i,
      pack_price: /prijs\b.*\bcolli/i,
      comment:    /^opm(erking)?/i,
    )

    linenum = 0
    category = nil

    sheet.each do |row|
      puts("[ROW] #{row.inspect}")
      linenum += 1
      row[:name].blank? and next
      # (sub)categories are in first two content cells - assume if there's a price it's a product
      if row[:number].blank? && row[:unit_price].blank?
        category = row[:name]
        next
      end
      # skip products without a number
      row[:number].blank? and next
      # extract name and unit
      errors = []
      notes = []
      unit_price = row[:unit_price]
      pack_price = row[:pack_price]
      number = row[:number]
      name = row[:name]
      unit = nil
      manufacturer = nil
      prod_category = nil
      RES_PARSE_UNIT.each do |re|
        m=name.match(re) or next
        unit = self.normalize_unit(m[3])
        name = name.sub(re, '').sub(/\(\s*\)\s*$/,'').sub(/\s+/, ' ').sub(/\.\s*$/, '').strip
        break
      end
      unit ||= '1 st' if name.match(/\bsla\b/i)
      unit ||= '1 bos' if name.match(/\bradijs\b/i)
      unit ||= '1 bosje' if category.match(/\bkruid/i)
      if unit.nil?
        unit = '?'
        errors << "Cannot find unit in name '#{name}'"
      end
      # handle multiple units in one line
      if unit.match(/\b(,\s+|of)\b/)
        # TODO create multiple articles instead of taking first one
      end
      # sometimes category is also used to indicate manufacturer
      m=category.match(/((eko\s*)?boerderij.*?)\s*$/i) and manufacturer = m[1]
      # Ad-hoc fix for package of eggs: always take pack price
      if name.match(/^eieren/i)
        unit_price = pack_price
        prod_category = 'Eieren'
      end
      prod_category = 'Kaas' if name.match(/^kaas/i)
      # figure out unit_quantity
      if unit.match(/x/)
        unit_quantity, unit = unit.split(/\s*x\s*/i, 2)
        unit,unit_quantity = unit_quantity,unit if unit_quantity.match(/[a-z]/i)
      elsif (unit_price-pack_price).abs < 1e-3
        unit_quantity = 1
      elsif m=unit.match(/^(.*)\b\s*(st|bos|bossen|bosjes?)\.?\s*$/i)
        unit_quantity, unit = m[1..2]
        unit_quantity.blank? and unit_quantity = 1
      else
        unit_quantity = 1
      end
      # there may be a more informative unit in the line
      if unit=='st' && !name.match(/kool/i)
        RES_PARSE_UNIT.each do |re|
          m=name.match(re) or next
          unit = self.normalize_unit(m[3])
          name = name.sub(re, '').strip
        end
      end
      # note from various fields
      notes.append("Skal #{row[:skal]}") if row[:skal].present?
      notes.append(row[:demeter]) if row[:demeter].present? && row[:demeter].is_a?(String)
      notes.append("Demeter #{row[:demeter]}") if row[:demeter].present? && row[:demeter].is_a?(Fixnum)
      notes.append "(#{row[:comment]})" unless row[:comment].blank?
      name.sub!(/(,\.?\s*)?\bDemeter\b/i, '') and notes.prepend("Demeter")
      name.sub!(/(,\.?\s*)?\bBIO\b/i, '') and notes.prepend "BIO"
      # unit check
      errors << check_price(unit, unit_quantity, unit_price, pack_price)
      # create new article
      name.gsub!(/\s+/, ' ')
      article = {:number => number,
                 :name => name.strip,
                 :note => notes.count > 0 && notes.map(&:strip).join("; "),
                 :manufacturer => manufacturer,
                 :origin => 'Noordoostpolder, NL',
                 :unit => unit,
                 :price => pack_price.to_f/unit_quantity.to_f,
                 :unit_quantity => unit_quantity,
                 :tax => 6,
                 :deposit => 0,
                 :category => prod_category || category
                 }
      errors.compact!
      if errors.count > 0
        yield article, errors.join("\n")
      else
        # outlisting not used by supplier
        yield article, nil
      end
    end
  end

  protected

  def self.check_price(unit, unit_quantity, unit_price, pack_price)
    if (unit_price-pack_price).abs < 1e-3
      return if unit_quantity == 1
      return "price per unit #{unit_price} is pack price, but unit quantity #{unit_quantity} is not one"
    end

    if m = unit.match(/^(.*)(#{RE_UNITS})\s*$/)
      amount, what = m[1..2]
    else
      return "could not parse unit: #{unit}"
    end

    # perhaps unit price is kg-price
    kgprice = if what =~ /^kg/i
                pack_price.to_f / amount.to_f
              elsif what =~ /^gr/
                pack_price.to_f / amount.to_f * 1000
              end
    if kgprice.present? && (kgprice - unit_price.to_f).abs < 1e-2
      return
    end

    unit_price_computed = pack_price.to_f/unit_quantity.to_i
    if (unit_price_computed - unit_price.to_f).abs > 1e-2
      "price per unit given #{unit_price.round(3)} does not match computed " +
        "#{pack_price.round(3)}/#{unit_quantity}=#{unit_price_computed.round(3)}" +
        (kgprice ? " (nor is it a kg-price #{kgprice.round(3)})" : '')
    end
  end

  def self.normalize_unit(unit)
    unit = unit.sub(/1\s*x\s*/, '')
    unit = unit.sub(/,([0-9])/, '.\1').gsub(/^per\s*/,'').sub(/^1\s*([^0-9.])/,'\1').sub(/^a\b\s*/,'')
    unit = unit.sub(/(bossen|bosjes?)/, 'bos').sub(/(liter|l\.|L\.)/,'ltr').sub(/stuks?/, 'st').sub('gram','gr')
    unit = unit.sub(/\s*\.\s*$/,'').sub(/\s+/, ' ').strip
  end

end
