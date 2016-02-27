class ChangeResetRequest < ActiveRecord::Migration
  def change
   add_column :reset_requests, :rejected, :boolean, default: false
   rename_column :reset_requests, :games_id, :game_id
  end
end