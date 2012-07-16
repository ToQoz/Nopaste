class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.string   "title"
      t.text     "body"
      t.string   "username"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def down
    drop_table :posts
  end
end
