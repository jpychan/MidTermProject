class Match < ActiveRecord::Base

  belongs_to :game

  belongs_to :player1,  class_name: "User",
                        foreign_key: "player1_id"
  belongs_to :player2, class_name: "User",
                        foreign_key: "player2_id"
  belongs_to :winner, class_name: "User",
                      foreign_key: "winner_id"
  belongs_to :loser, class_name: "User",
                      foreign_key: "loser_id"

  validate :player1_player2_are_different

  def player1_player2_are_different
    if player1_id == player2_id
      errors.add(:players, "The players can't be the same!")
    end
  end

  def participant?(current_user)
    if current_user == player1_id || current_user == player2_id
    end
  end


end
