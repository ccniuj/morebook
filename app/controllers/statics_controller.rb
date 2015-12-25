class StaticsController < ApplicationController
  def index
    # @books = @paginate = Book.paginate(:page => params[:page])
    @shelves = Shelf.offset(rand(Shelf.count)).limit(8)
  end

  def search
    @query = params[:query]
    uri = URI::encode(utf8_to_uri_encoding(@query))
    c = Crawler.new
    @result = c.search(uri)
  end

  private
  def utf8_to_uri_encoding(str)
    ascii = str.force_encoding('ASCII-8BIT')
    str.force_encoding('UTF-8')
    ascii
  end
end