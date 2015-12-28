class Book < ActiveRecord::Base
  has_many :pictures, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :shelf_books, dependent: :destroy
  has_many :shelves, through: :shelf_books
  has_many :book_tags, dependent: :destroy
  has_many :tags, through: :book_tags
  
  def save_image(images)
    images.each do |img|
      self.pictures.create(:image => img)
    end
  end

  def self.add_book_to_shelf(user, book_data, shelves_id)
    if book_data.class == self
      book = book_data
    else
      book = self.where(:isbn => book_data[:isbn]).first
      if book.nil?
        book = self.add_book_to_db(book_data)
      end
    end

    book.shelf_books.each {|s| s.destroy }    
    shelves_id.each do |s_id|
      book.shelf_books.create(:book_id => book, :shelf_id => s_id)
    end
    
    book
  end

  def self.add_book_to_db(book_data)
    cover_url = book_data.delete(:cover_url)
    book = self.new(book_data)
    book.save

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