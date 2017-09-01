#
# Rake tasks for receiving article updates by email.
#
# Mail setup is heavily inspired by Foodsoft's reply-by-mail feature for messages
# @see https://github.com/foodcoops/foodsoft/blob/master/plugins/messages/lib/tasks/foodsoft.rake
#
require "mail"
require "midi-smtp-server"

class ReplyEmailSmtpServer < MidiSmtpServer::Smtpd

  def start
    super
    @to = nil
    @from = nil
  end

  def on_mail_from_event(ctx, from)
    @from = from
  end

  def on_rcpt_to_event(ctx, to)
    @to = to
  end

  def on_message_data_event(ctx)
    m = /<(?<recipient>[^<>]+)>/.match(@to)
    raise "invalid format for RCPT TO" if m.nil?
    handle_mail(m[:recipient], ctx[:message][:data])
  rescue => error
    Rails.logger.error(error.message)
    # @todo notify sysadmin
  end

end

namespace :mail do
  desc "Parse incoming email on stdin (options: RECIPIENT=1.a1b2c3d3e5)"
  task :parse_reply_email => :environment do
    hande_mail(ENV['RECIPIENT'], STDIN.read)
  end

  desc "Start STMP server for incoming email (options: SMTP_SERVER_PORT=2525, SMTP_SERVER_HOST=127.0.0.1)"
  task :smtp_server => :environment do
    port = (ENV['SMTP_SERVER_PORT'] || 2525).to_i
    host = ENV['SMTP_SERVER_HOST'] || '127.0.0.1'
    rake_say "Started SMTP server for incoming email on #{host}:#{port}."
    server = ReplyEmailSmtpServer.new(port, host)
    server.start
    server.join
  end
end

def handle_mail(recipient, received_email)
  m = /(?<supplier_id>\d+)\.(?<hash>\w+)(@(?<hostname>.*))?/.match(recipient)
  raise "Recipient is missing or has an invalid format: #{recipient}" if m.nil?

  supplier = Supplier.find_by_id(m[:supplier_id])
  raise "Supplier id #{m[:supplier_id]} could not be found" if supplier.nil?

  hash = supplier.articles_mail_hash
  hash.casecmp(m[:hash]) == 0 or raise "Hash '#{hash}' does not match expectations for supplier #{supplier.name}"

  message = Mail.new(received_email)

  # message checks
  if supplier.mail_from.present?
    m, s = message.from, supplier.mail_from
    m.any? {|n| n.include?(s) } or raise "Expected to find '#{s}' in from address '#{m.join(', ')}' for supplier #{supplier.name}"
  end
  if supplier.mail_subject.present?
    m, s = message.subject, supplier.mail_subject
    m.downcase.include?(s.downcase) or raise "Expected to find '#{s}' in subject '#{m}' for supplier #{supplier.name}"
  end

  # get attachment
  filename = nil
  message.attachments.each do |part|
    # @todo perhaps get heuristic from article import filters?
    if part.filename.match(/\.(xls|xlsx|ods|sxc|csv|tsv|xml)$/i)
      FileUtils.mkdir_p(supplier.mail_path)
      filename = "#{message.date.strftime '%Y%m%d'}_#{part.filename.gsub(/[^-a-z0-9_\.]+/i, '_')}"
      filename = supplier.mail_path.join(filename)
      File.open(filename, 'w+b') { |f| f.write part.body.decoded }
    end
  end

  raise "No spreadsheet attachment found" unless filename.present?

  # import!
  outlisted_counter, new_counter, updated_counter, invalid_articles =
      supplier.update_articles_from_file(File.new(filename), type: supplier.mail_type)

  msg = "Handled articles update email for #{supplier.name}: "
  msg += "#{new_counter} new, #{updated_counter} updated, #{outlisted_counter} outlisted, #{invalid_articles.size} invalid"
  invalid_articles.map do |article|
    msg += "\n* invalid article '#{article.name}'"
    article.errors.each do |attr, errmsg|
      errmsg.split("\n").each do |l|
        msg += "\n  - #{': ' unless attr.blank?}" + l
      end
    end
  end

  rake_say msg
end

# Helper
def rake_say(message)
  puts message unless Rake.application.options.silent
end
