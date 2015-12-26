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
  
  def save_image(images)
    images.each do |img|
      self.pictures.create(:image => img)
    end
  end

end