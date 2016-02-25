class ResetRequest < ActiveRecord::Base

  belongs_to :games

  has_and_belongs_to_many :requester, :class_name => "User"
  has_and_belongs_to_many :requested, :class_name => "User"

end