class Game < ActiveRecord::Base

  has_many :matches
  has_many :reset_requests

  validates :title, presence: true
  validates :shortname, presence: true

end