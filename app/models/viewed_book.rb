class ViewedBook < ActiveRecord::Base
	def self.list_recent_five_viewed_books(session_id, user)
    viewed_books = self.find_by(:session_id => session_id).books_id.split(',').
                        map{|b|Book.find_by(:id => b.to_i)}
    viewed_books.shift
    viewed_books.first(5)
  end

  def self.update_user_id(sid, user)
  	viewed_books = self.find_by(:session_id => sid)
  	if viewed_books && user
  		viewed_books.update(:user_id => user.id)
  	end
  end

  def self.update_session_id(current_sid, old_sid)
    prev_viewed_books = self.find_by(:session_id => old_sid)
    if prev_viewed_books
      prev_viewed_books.update(:session_id => current_sid)
    end
  end
end