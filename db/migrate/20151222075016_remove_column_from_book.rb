class RemoveColumnFromBook < ActiveRecord::Migration
  def change
    remove_column :books, :tag_id
  end
end
