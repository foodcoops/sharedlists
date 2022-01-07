# encoding:utf-8
desc "Import articles from file (options: FILE=f, TYPE=t, SUPPLIER=id_or_name)"
task 'import:articles': :environment do |t, args|
  filename = ENV['FILE']
  filename.present? or raise 'Please set FILE to the file to import'

  type = ENV['TYPE']
  types_avail = ArticleImport.file_formats.keys
  types_avail.include?(type) or raise "Please set TYPE to one of: #{types_avail.join(', ')}"

  supplier = Supplier.where('id = ? OR name = ?', ENV['SUPPLIER'], ENV['SUPPLIER']).first
  supplier.present? or raise 'Please set SUPPLIER to a supplier id or name'

  outlisted_counter, new_counter, updated_counter, invalid_articles = begin
    Article.transaction do
      supplier.update_articles_from_file(File.new(filename), type: type)
    end
  end

  # show result
  # @todo remove code duplication with mail_sync
  puts "* imported: #{new_counter} new, #{updated_counter} updated, #{outlisted_counter} outlisted, #{invalid_articles.size} invalid"
  invalid_articles.each do |article|
    puts "- invalid article '#{article.name}'"
    article.errors.each do |attr, msg|
      msg.split("\n").each do |l|
        puts "  · #{attr.blank? ? '' : "#{attr}: "} #{l}"
      end
    end
  end
end
