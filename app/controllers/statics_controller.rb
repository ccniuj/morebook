class StaticsController < ApplicationController
  def index
    # @books = @paginate = Book.paginate(:page => params[:page])
    @shelves = Shelf.offset(rand(Shelf.count)).limit(8)
  end

  def search
    @query = params[:query]
    unless @query.empty?
      uri = URI::encode(utf8_to_uri_encoding(@query))
      c = Crawler.new
      @results = c.books_search(uri)

      session[:books_search] = @results
    else
      redirect_to root_path
    end
  end

  def book
    book_id = params[:id]
    book = find_by_product_id(book_id)[0]
    c = Crawler.new
    if book
      @book = c.get_book_info(book[:href])
      @book_db = Book.where(:isbn => @book[:isbn]).first
      if @book_db
        redirect_to book_path(@book_db.id)
      end
      session[@book[:isbn]] = @book
    else
      redirect_to root_path
    end
  end

  def add_book_to_db
    book_isbn = params[:isbn]
    if book_isbn
      book_data = session[book_isbn]
      cover_url = book_data.delete(:cover_url)

      book = Book.new(book_data)
      book_cover = book.pictures.build(:image => cover_url)
      if book.save && book_cover.save
        redirect_to book_path(book)
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  private
  def utf8_to_uri_encoding(str)
    ascii = str.force_encoding('ASCII-8BIT')
    str.force_encoding('UTF-8')
    ascii
  end

  def find_by_product_id(book_id)
    entries = session[:books_search]
    if entries
      result = entries.select { |entry| entry[:product_id][0] == book_id }
    else
      result = []
    end
  end
end