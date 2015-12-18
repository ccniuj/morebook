class StaticsController < ApplicationController
  def index
    @books = @paginate = Book.paginate(:page => params[:page])
  end
end