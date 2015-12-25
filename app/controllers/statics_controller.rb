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
    book = find(book_id)[0]
    c = Crawler.new
    @book = c.get_book_info(book[:href])
  end

  private
  def utf8_to_uri_encoding(str)
    ascii = str.force_encoding('ASCII-8BIT')
    str.force_encoding('UTF-8')
    ascii
  end

  def find(book_id)
    entries = session[:books_search]
    result = entries.select { |entry| entry[:product_id][0] == book_id }
  end
end