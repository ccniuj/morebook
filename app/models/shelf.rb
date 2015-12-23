class Shelf < ActiveRecord::Base
  has_many :user_shelves
  has_many :users, through: :user_shelves
  has_many :shelf_books
  has_many :books, through: :shelf_books

  has_attached_file :cover, styles: { medium: "300x300#", thumb: "100x100#" }, 
    default_url: '/images/:styles/missing.png'
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/

  def self.owned_by(user)
    Shelf.select("shelves.*, user_shelves.user_id").
          joins('LEFT JOIN user_shelves ON user_shelves.shelf_id = shelves.id').
          where("user_shelves.user_id = ?", user.id)
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
end