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

  def self.owned_by(user)
    Shelf.select("shelves.*, user_shelves.user_id").
          joins('LEFT JOIN user_shelves ON user_shelves.shelf_id = shelves.id').
          where("user_shelves.user_id = ?", user.id)
  end


end