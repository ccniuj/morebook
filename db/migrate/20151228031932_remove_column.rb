class RemoveColumn < ActiveRecord::Migration
  def change
    remove_column :books, :user_id
    remove_column :shelf_books, :is_local?
    remove_attachment :books, :cover
  end
end
