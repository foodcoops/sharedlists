# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
SharedLists::Application.config.secret_token = begin
  if (token = ENV['SECRET_TOKEN']).present?
    token
  elsif Rails.env.production? || Rails.env.staging?
    raise "You must set SECRET_TOKEN"
  elsif Rails.env.test?
    SecureRandom.hex(30) # doesn't really matter
  else
    sf = Rails.root.join('tmp', 'secret_token')
    if File.exists?(sf)
      File.read(sf)
    else
      puts "=> Generating initial SECRET_TOKEN in #{sf}"
      token = SecureRandom.hex(30)
      File.open(sf, 'w') { |f| f.write(token) }
      token
    end
  end
end
