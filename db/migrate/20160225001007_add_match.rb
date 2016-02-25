class AddMatch < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :games
      t.references :player1
      t.references :player2
      t.references :winner
      t.references :loser
      t.timestamps
    end
  end
end
