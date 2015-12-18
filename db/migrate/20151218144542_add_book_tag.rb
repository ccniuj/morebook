class AddBookTag < ActiveRecord::Migration
  def change
    add_column :books, :tag_id, :integer, :null => false
  end
end
