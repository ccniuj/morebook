module BooksHelper
  def normalize(html)
    html.scan(/(.+)\n(.+)/).join
  end
end
