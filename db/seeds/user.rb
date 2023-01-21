# Create admin user
User.create!(
  :email => "admin@example.com",
  :password => "secret",
  :admin => true
)
