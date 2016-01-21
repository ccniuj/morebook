class Shelf < ActiveRecord::Base
  has_many :user_shelves, dependent: :destroy
  has_many :users, through: :user_shelves
  has_many :shelf_books, dependent: :destroy
  has_many :books, through: :shelf_books

  has_attached_file :cover, styles: { medium: "300x300#", thumb: "100x100#" }, 
    default_url: '/images/:styles/missing.png'
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/
  
  def self.owned_by(user)
    self.joins('LEFT JOIN user_shelves ON user_shelves.shelf_id = shelves.id').
         where("user_shelves.user_id = ?", user.id).
         where('user_shelves."is_owner?" = true')
  end

  def self.tag_filter(tag_name)

  end

  def count_tags
    counter = {}
    self.books.each do |book|
      book.tags.each do |tag|
        counter[tag.name] ||= 0
        counter[tag.name] += 1
      end
    end
    counter.delete('中文書')
    counter
  end

  def main_tag
    counter = self.count_tags
    r = counter.reduce(['', 0]) { |result, c| (c[1] < result[1]) ? result : c }
    (r[0] == '') ? 'None' : r[0]
  end

  def list_tags
    list = self.count_tags.keys
  end

  def self.filter_by_tag(tag_name)
    return self.all if tag_name.nil?
    tag = Tag.where(:name => tag_name).first
    self.joins('LEFT JOIN shelf_books ON shelves.id = shelf_books.shelf_id').
         joins('LEFT JOIN book_tags ON shelf_books.book_id = book_tags.book_id').
         where("book_tags.tag_id = #{tag.id}").
         uniq
  end

  def self.fake_shelves
    Tag.all.select {|t|t.depth==3}.each do |tag|
      shelf = self.create(:name => "#{tag.name}相關")
      UserShelf.create(:user_id  => User.where(email:'davidjuin0519@gmail.com').first.id, 
                       :shelf_id => shelf.id)
      tag.books.each do |book|
        ShelfBook.create(:shelf_id => shelf.id,
                         :book_id => book.id)
      end

      random_book = tag.books.shuffle.first
      if random_book
        shelf.update(:cover => random_book.cover_url, :description => random_book.description)
      end
      p "Shelf of tag #{tag.name} has been created."
    end
  end
end