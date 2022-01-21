class User < ApplicationRecord

  has_many :user_accesses, :dependent => :destroy
  has_many :suppliers, :through => :user_accesses

  attr_reader :password

  validates :email, presence: true, uniqueness: true
  validates :password, confirmation: true
  validate do |user|
    unless user.password_hash.present? && user.password_salt.present?
      user.errors.add :password, :blank
    end
  end

  def self.attributes_protected_by_default
    super + %w(password_hash password_salt)
  end

  def has_access_to?(supplier)
    admin? or !UserAccess.where(supplier_id: supplier.id, user_id: id).first.nil?
  end

  def authenticate(password_plain)
    if self.password_hash == BCrypt::Engine.hash_secret(password_plain, self.password_salt)
      self
    else
      false
    end
  end

  def password=(password_plain)
    @password = password_plain
    unless password_plain.blank?
      new_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password_plain, new_salt)
      self.password_salt = new_salt
    end
  end

  def admin?
    !!admin
  end
end
