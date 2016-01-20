class CreateRatedBook < ActiveRecord::Migration
  def change
    create_table :rated_books do |t|
    	t.string :user_id
    	t.string :session_id
    	t.text :books_and_time_stamps
    	t.timestamps
    end
  end
end
