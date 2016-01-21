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

  def rate_distribution
    total = self.rates.count
    counts = self.rates.reduce({}) do |result, rate|
               key = rate.score
               score_range = [*0..3]
               score_range.each do |score|
                 result[score] ||= 0
               end
               result[key] += 1
               result
             end.
             sort_by{|k, v|k}.reverse.to_h.
             map do |k, v|
               h = {}
               v = (v.to_f/total).round(2)
               h[score_to_text(k)] = v
               h
             end
    counts
  end

  def avg_score
    counts = self.rates.count
    total = self.rates.reduce(0){|sum, i|sum += i.score}
    (counts > 0) ? (total.to_f / counts).round.to_i : 0.0
  end

  def record_viewed_book(sid, user)
    viewed_books = ViewedBook.find_by(:session_id => sid)
    if viewed_books.nil?
        viewed_books = ViewedBook.create(:session_id  => sid,
                                         :books_id    => self.id.to_s)
        viewed_books.update(:user_id => user.id) if user
    end

    books_id = viewed_books.books_id.split(',').map{|v|v.to_i}
    if books_id.include?(self.id)
      books_id.unshift(books_id.delete(self.id))
    else
      books_id.unshift(self.id)
    end
    books_id = books_id.join(',')
    viewed_books.update(:books_id => books_id)
  end
  
  def record_rated_book(sid, user)
    rated_books = RatedBook.find_by(:session_id => sid)
    if rated_books.nil?
        rated_books = RatedBook.create(:session_id  => sid,
                                       :books_and_time_stamps => "#{self.id}/#{Time.now}")
        rated_books.update(:user_id => user.id) if user
    end

    books_and_time_stamps = rated_books.books_and_time_stamps.split(',').map do |v|
      [v.split('/')[0].to_i, v.split('/')[1].to_datetime]
    end

    if books_and_time_stamps.map{|b|b[0]}.include?(self.id)
      books_and_time_stamps.delete_if{|b|b[0]==self.id}
    end

    books_and_time_stamps.unshift([self.id, Time.now])
    books_and_time_stamps = books_and_time_stamps.map{|b|b.join('/')}.join(',')

    rated_books.update(:books_and_time_stamps => books_and_time_stamps)
  end

  def check_if_rated_recently(sid)
    rated_books = RatedBook.find_by(:session_id => sid)

    if rated_books
      books_and_time_stamps = rated_books.books_and_time_stamps.split(',').map do |v|
        [v.split('/')[0].to_i, v.split('/')[1].to_datetime]
      end
      books_rated_recently = books_and_time_stamps.select do |bs|
        bs[0]==self.id && ((Time.now.to_date - bs[1].to_date).to_i<1.month)
      end
      if books_rated_recently.any?
        return true
      end
    end

    false
  end
  
  private

  def score_to_text(score)
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