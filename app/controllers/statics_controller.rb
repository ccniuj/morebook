class StaticsController < ApplicationController
  def index
    # @books = @paginate = Book.paginate(:page => params[:page])
    @shelves = Shelf.offset(rand(Shelf.count)).limit(8)
  end

  def search
    @query = params[:query]
    c = Crawler.new
    @result = c.watir_webdriver(@query)
  end
end