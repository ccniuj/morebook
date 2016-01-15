class ViewedBook < ActiveRecord::Base
	def self.list_recent_five_viewed_books(session_id, user_id=nil)
    viewed_books = self.find_by(:session_id => session_id).books_id.split(',').
                        map{|b|Book.find_by(:id => b.to_i)}
    viewed_books.shift
    viewed_books.first(5)
  end
end