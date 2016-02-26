class User < ActiveRecord::Base
  has_secure_password

  has_many :reset_requests

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { in: 6..20 }

  def matches
    Match.where("player1_id = ? OR player2_id = ?", self.id, self.id)
  end

end
