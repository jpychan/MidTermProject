class AddUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :password_digest
      t.string :picture_url
      t.timestamps
    end
  end
end
