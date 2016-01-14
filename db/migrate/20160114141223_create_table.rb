class CreateTable < ActiveRecord::Migration
  def change
    create_table :viewed_books do |t|
    	t.string :user_id
    	t.string :session_id
    	t.text :books_id
    	t.timestamps
    end
  end
end
