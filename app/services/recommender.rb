class Recommender
	def self.sim_distance(data, book_id_1, book_id_2)
		common = []
		data[book_id_1.to_s].each do |user_id|
			common.push(user_id) if data[book_id_2.to_s].include?(user_id)
		end
		common.each do |c|
			data[book_id_1].delete(c)
			data[book_id_2].delete(c)
		end
		sum = data[book_id_1].count + data[book_id_2].count
		sim_distance = 1.0 / (1.0 + sum)
	end

	def self.top_matches(data, book_id, n=5)
		distances = {}
		data.keys.each do |other_book_id|
  		distances[other_book_id] = sim_distance(data, book_id, other_book_id) if (book_id != other_book_id)
		end
		distances.sort_by{|k, v|v}.reverse.first(n).to_h
	end

	def self.calculate_similar_items(data, n=10)
		results = {}
		data.keys.each_with_index do |book_id, i|
			p "iteration ##{i+1}"
			results[book_id] = top_matches(data, book_id, n)
		end
		results
	end

	def self.get_recommendations(data, all_top_matches, user_id)
		total = {}
		# counts = {}
		# rankings = {}
		viewed_books_id = ViewedBook.find_by(:user_id => user_id).books_id.split(',')
		viewed_books_id.each do |vb|
			all_top_matches[vb].each do |k, v|
				next if viewed_books_id.include?(k)
				total[k] ||= 0; total[k] += v
				# counts[k] ||= 0; counts[k] += 1
			end
		end
		# total.keys.each do |k|
		# 	rankings[k] = total[k]/counts[k]
		# end
		total.sort_by{|k, v|v}.reverse.to_h.keys.first(5)
	end
end

# Recommender.sim_distance(ViewedBook.book_viewed_list, '11425', '11424')
# Recommender.top_matches(ViewedBook.book_viewed_list, '11425')
