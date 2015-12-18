class Shelf < ActiveRecord::Base
  has_many :user_shelves
  has_many :users, through: :user_shelves
  has_many :shelf_books
  has_many :books, through: :shelf_books
end