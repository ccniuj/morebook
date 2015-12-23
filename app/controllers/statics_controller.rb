class StaticsController < ApplicationController
  def index
    # @books = @paginate = Book.paginate(:page => params[:page])
    @shelves = Shelf.offset(rand(Shelf.count)).limit(8)
  end
end