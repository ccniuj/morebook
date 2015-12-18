class InitMorebook < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.string :name
      t.text :description
      t.timestamps
      t.timestamp :delete_at
    end
    create_table :user_shelves do |t|
      t.integer :user_id
      t.integer :shelf_id
      t.boolean :is_owner?
    end
    create_table :books do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :author
      t.string :isbn
      t.string :publisher
      t.datetime :publish_date
      t.string :language
      t.string :page
      t.timestamps
      t.timestamp :delete_at
    end
    create_table :shelf_books do |t|
      t.integer :shelf_id
      t.integer :book_id
      t.integer :user_id
      t.integer :is_local?
    end
    create_table :stars do |t|
      t.integer :user_id
      t.integer :book_id
      t.timestamps
    end
    create_table :tags do |t|
      t.string :name
      t.timestamps
      t.timestamp :delete_at
    end
    create_table :notes do |t|
      t.integer :book_id
      t.integer :user_id
      t.text :content
    end
    create_table :comments do |t|
      t.integer :book_id
      t.integer :user_id
      t.text :content
    end
    create_table :rates do |t|
      t.integer :book_id
      t.integer :user_id
      t.integer :score
    end
    add_index :user_shelves, [:user_id, :shelf_id]
    add_index :shelf_books, [:book_id, :shelf_id]
    add_index :books, :user_id
  end
end
