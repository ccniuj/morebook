class AddColumnTotag < ActiveRecord::Migration
  def change
    add_column :tags, :lft, :integer, :null => false
    add_column :tags, :rgt, :integer, :null => false
    add_column :tags, :parent_id, :integer, :null => true
    add_column :tags, :depth, :integer, :null => false, :default => 0
    add_column :tags, :children_count, :integer, :null => false, :default => 0
    add_index :tags, :lft
    add_index :tags, :rgt
    add_index :tags, :parent_id
  end
end
