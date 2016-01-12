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
  
  def hierarchy_tag_hash(current_nodes=nil)
    current_nodes ||= [Tag.root]

    current_nodes.map do |cn|
      {
        :tag_id => cn.id,
        :parent_tag_id => cn.parent ? cn.parent.id : nil,
        :text => cn.name,
        :state => {:checked => self.tags.all.include?(cn), :expanded => (cn.depth<2) ? true : false},
        :nodes => cn.children.any? ? self.hierarchy_tag_hash(cn.children) : nil 
      }      
    end
  end

  def self.add_book_to_shelf(user, book_data, shelves_id)
    if book_data.class == self
      book = book_data
    else
      book = self.where(:isbn => book_data[:isbn]).where(:name => book_data[:name]).first
      if book.nil?
        book = self.add_book_to_db(book_data)
      end
    end

    current_shelves_id = user.shelves.joins(:shelf_books).
      where('shelf_books.book_id = ?', book.id).
      uniq.map {|s| s.id}

    shelves_id.each do |s_id|
      if current_shelves_id.exclude?(s_id)
        book.shelf_books.create(:book_id => book, :shelf_id => s_id)
      end
    end

    current_shelves_id.each do |cs_id|
      if shelves_id.exclude?(cs_id)
        book.shelf_books.where(shelf_id: cs_id).first.delete
      end
    end
    
    book
  end

  def self.add_book_to_db(book_data)
    tag_name = book_data.delete(:tag)

    book = self.new(book_data)
    book.save

    # book.save_image([cover_url])
    book.tagging(tag_name)

    book
  end

  def tagging(name)
    tag = Tag.where(:name => name).take
    BookTag.create(:book_id => self.id, :tag_id => tag.id)
    while tag.parent
      tag = tag.parent
      bt = BookTag.where(:book_id => self.id).where(:tag_id => tag.id).take
      if bt.nil?
        BookTag.create(:book_id => self.id, :tag_id => tag.id)
      end
    end
  end

  def remove_book_from_each_shelf(user)
    user.user_shelves.select{|us|us.is_owner?}.map{|us|us.shelf}.flatten
        .select{|s|s.books.include?(self)}.map{|s|s.shelf_books}.flatten
        .each{|sb|sb.delete if sb.book_id == self.id}
  end

  def self.kept_by(user)
    self.joins('INNER JOIN shelf_books ON books.id = shelf_books.book_id').
         joins('INNER JOIN user_shelves ON shelf_books.shelf_id = user_shelves.shelf_id').
         joins('LEFT JOIN book_tags ON books.id = book_tags.book_id').
         joins('LEFT JOIN tags ON book_tags.tag_id = tags.id').
         where('user_shelves.user_id = ?', user.id).
         where('user_shelves."is_owner?" = true').
         uniq
  end

  def self.filter_by_tag(tag_name)
    return self.all if tag_name.nil?
    tag_id = Tag.where(:name => tag_name).first.id
    self.joins('LEFT JOIN book_tags on books.id = book_tags.book_id').
         where('book_tags.tag_id = ?', tag_id).
         uniq
  end

  def rating_distribution
    results = []
    total = self.rates.count
    counts = self.rates.reduce({}) do |result, rate|
               key = rate.score
               result[key] ||= 0
               result[key] += 1
               result
             end
             .sort_by{|k, v|k}.reverse.to_h
    results = counts.map do |k, v|
                h = {}
                v = (v.to_f/total).round(2)
                h[to_text(k)] = v
                h
              end
  end

  private

  def to_text(score)
    case score
    when 0
      '免讀'
    when 1
      '可讀'
    when 2
      '應讀'
    when 3
      '必讀'
    end
  end
end