class BooksController < ApplicationController
  def index
    @books = @paginate = Book.paginate(:page => params[:page])
  end

  def show
    @book = Book.joins(:shelves).joins(:tags).find(params[:id])
  end
end