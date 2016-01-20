class RatedBook < ActiveRecord::Base
	belongs_to :user

	def self.update_user_id(sid, user)
  	rated_books = self.find_by(:session_id => sid)
  	if rated_books && user
  		rated_books.update(:user_id => user.id)
  	end
  end

  def self.update_session_id(current_sid, old_sid)
    prev_rated_books = self.find_by(:session_id => old_sid)
    if prev_rated_books
      prev_rated_books.update(:session_id => current_sid)
    end
  end

end