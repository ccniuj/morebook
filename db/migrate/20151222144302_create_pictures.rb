class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.integer :book_id
      t.has_attached_file :image
      t.boolean :is_cover?
    end
  end
end
