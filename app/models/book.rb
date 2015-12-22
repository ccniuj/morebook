class Book < ActiveRecord::Base
  belongs_to :user
  has_many :pictures
  has_many :notes 
  has_many :comments
  has_many :rates
  has_many :shelf_books
  has_many :shelves, through: :shelf_books
  has_many :book_tags
  has_many :tags, through: :book_tags
  
  # has_attached_file :cover, styles: { medium: "300x300>", thumb: "100x100>" }, 
  #   default_url: "/images/:styles/missing.png"
  # validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/

  def save_image(img)
    self.pictures.create(:image => img)
  end
end