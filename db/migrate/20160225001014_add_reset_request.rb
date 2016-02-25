class AddResetRequest < ActiveRecord::Migration
  def change
    create_table :reset_requests do |t|
      t.references :requester
      t.references :requested
      t.references :games
      t.boolean :confirmed, default: false
      t.timestamps
    end
  end
end
