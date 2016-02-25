class MatchUpdate < ActiveRecord::Migration
  def change
    rename_column :matches, :games_id, :game_id
  end
end
