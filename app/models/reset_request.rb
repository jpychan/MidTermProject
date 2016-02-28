 class ResetRequest < ActiveRecord::Base

  belongs_to :game

  belongs_to :requester, class_name: "User",
                          foreign_key: "requester_id"

  belongs_to :requested, class_name: "User",
                          foreign_key: "requested_id"

  
  def unique_pending_request?(current_user, requested_user, game)
    all_requests = ResetRequest.where("(requester_id = ? and requested_id = ? and game_id = ?) or (requester_id = ? and requested_id = ? and game_id = ?)", current_user, requested_user, game, requested_user, current_user, game)
    pending_requests = all_requests.where(confirmed: false, rejected: false)
    if pending_requests.count == 0
      true
    end
  end
end