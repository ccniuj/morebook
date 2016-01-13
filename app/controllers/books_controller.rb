class BooksController < ApplicationController
  def index
    @tag_name = params[:tag] if params[:tag]
    @books = @paginate = Book.filter_by_tag(@tag_name).order('id DESC').paginate(:page => params[:page])
  end

  def show
    @book = Book.find(params[:id])
    @rate_distribution = @book.rate_distribution
    @avg_score = @book.avg_score
  end

  def add_book_to_shelf
    book_id = params[:book_id]
    book_show_url = params[:book_show_url]
    shelves_id = params[:shelves_id]

    book = Book.find(book_id)
      
    session[:user_return_to] = book_show_url
    authenticate_user!
    session[:user_return_to] = nil

    book_saved = Book.add_book_to_shelf(current_user, book, shelves_id)
    redirect_to book_path(book_saved)
  end

  def add_rate
    @book = Book.find(params[:book])
    score = params[:score]
    @book.rates.create(:score => score)

    respond_to do |format|
      format.html
      format.json {render json: [@book.rate_distribution, @book.avg_score]}
    end
  end
end