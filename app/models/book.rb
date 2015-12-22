class Book < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  has_many :notes 
  has_many :comments
  has_many :rates
  has_many :shelf_books
  has_many :shelves, through: :shelf_books
  
  has_attached_file :cover,
    styles: {
      original: "1024x1024>",
      medium: "300x300>",
      thumb: "100x100"
    }, 
    default_url: '/images/missing.jpg'
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/

end