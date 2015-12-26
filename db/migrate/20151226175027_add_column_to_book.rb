class AddColumnToBook < ActiveRecord::Migration
  def change
    add_column :books, :name_en, :string
    add_column :books, :author_en, :string
    add_column :books, :author_intro, :text
    add_column :books, :outline, :text
    add_column :books, :review, :text
  end
end
