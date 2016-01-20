class StaticsController < ApplicationController
  before_action :update_viewed_books_data, :only => :index
  before_action :update_rated_books_data, :only => :index

  def update_viewed_books_data
    current_sid = request.session_options[:id]
    old_sid = cookies[:sid_backup]
    ViewedBook.update_session_id(current_sid, old_sid)
    ViewedBook.update_user_id(current_sid, current_user)
  end

  def update_rated_books_data
    current_sid = request.session_options[:id]
    old_sid = cookies[:sid_backup]
    RatedBook.update_session_id(current_sid, old_sid)
    RatedBook.update_user_id(current_sid, current_user)
  end

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
      @book_db = Book.where(:isbn => @book[:isbn]).where(:name => @book[:name]).first
      if @book_db
        redirect_to book_path(@book_db.id)
      end
      session[@book[:isbn]] = @book
    else
      redirect_to root_path
    end
  end

  def profile
    @user = User.find(params[:id])
    @profile = @user.profile
  end

  def add_book_to_shelf
    book_isbn = params[:isbn]
    book_data_url = params[:book_data_url]
    shelves_id = params[:shelves_id]

    if book_isbn
      book_data = session[book_isbn]
      
      session[:user_return_to] = book_data_url
      authenticate_user!
      session[:user_return_to] = nil

      book_saved = Book.add_book_to_shelf(current_user, book_data, shelves_id)
      redirect_to book_path(book_saved)
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

  def find_product_id_by_isbn(isbn)

  end
end