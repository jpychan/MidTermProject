class Match < ActiveRecord::Base

belongs_to :games

has_and_belongs_to_many :player1, :class_name => "User"
has_and_belongs_to_many :player2, :class_name => "User"
has_and_belongs_to_many :winner, :class_name => "User"
has_and_belongs_to_many :loser, :class_name => "User"

end



