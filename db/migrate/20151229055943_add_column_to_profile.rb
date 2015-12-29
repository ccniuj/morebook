class AddColumnToProfile < ActiveRecord::Migration
  def change
    add_attachment :profiles, :selfie
    add_column :profiles, :description, :text
  end
end
