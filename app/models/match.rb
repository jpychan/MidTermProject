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

  #Checks that the players are different before saving the match
  #Used in posting a new match
  def player1_player2_are_different
    if player1_id == player2_id
      errors.add(:players, "The players can't be the same!")
    end
  end

  #Checks that the current user is a participant of the match
  #Used in editing a match
  def participant?(current_user_id)
    if current_user_id == player1_id || current_user_id == player2_id
      true
    end
  end

end
