class Shelf < ActiveRecord::Base
  has_many :user_shelves
  has_many :users, through: :user_shelves
  has_many :shelf_books
  has_many :books, through: :shelf_books

  has_attached_file :cover,
    styles: {
      original: "1024x1024>",
      medium: "300x300>",
      thumb: "100x100"
    }, 
    default_url: '/images/missing.jpg'
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/  
end