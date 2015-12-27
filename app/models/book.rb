class Book < ActiveRecord::Base
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

  def self.add_book_to_db(user, book_data)
    cover_url = book_data.delete(:cover_url)
    book = self.new(book_data)

    book.save

    shelf = user.shelves.first
    book.shelf_books.create(:book_id => book, :shelf_id => shelf.id)

    book_cover = book.save_image([cover_url])
    book
  end

  def self.kept_by(user)
    self.joins('INNER JOIN shelf_books ON books.id = shelf_books.book_id ').
         joins('INNER JOIN user_shelves ON shelf_books.shelf_id = user_shelves.shelf_id ').
         where('user_shelves.user_id = ?', user.id).
         uniq
  end
end