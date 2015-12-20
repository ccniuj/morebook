class AddColumnToShelf < ActiveRecord::Migration
  def change
    add_attachment :shelves, :cover
  end
end
