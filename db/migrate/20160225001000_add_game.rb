class AddGame < ActiveRecord::Migration
  def change
    create_table :games do |t|
    t.string :title
    t.string :shortname
    t.string :picture_url
    t.timestamps
   end
  end
end
