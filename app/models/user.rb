class User < ActiveRecord::Base
  has_secure_password
  
  has_many :matches
  has_many :reset_requests

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { in: 6..20 }
  
end