class Match < ActiveRecord::Base

# validate that player 1 and player 2 are not the same
# validate that winner and loser aren't the same

belongs_to :game

belongs_to :player1,  class_name: "User",
                      foreign_key: "player1_id"
belongs_to :player2, class_name: "User",
                      foreign_key: "player2_id"
belongs_to :winner, class_name: "User",
                    foreign_key: "winner_id"
belongs_to :loser, class_name: "User",
                    foreign_key: "loser_id"

end
