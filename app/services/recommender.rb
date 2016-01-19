class Recommender
	Book_count = Book.all.count

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

	def self.sim_pearson(data, book_id_1, book_id_2)
		# gradient descent
		common = []
		data[book_id_1.to_s].each do |user_id|
			common.push(user_id) if data[book_id_2.to_s].include?(user_id)
		end
		z = data[book_id_1].count
		x = data[book_id_2].count
		y = common.count
		w = Book_count + y - z - x
		gamma = 0.01
		error = 0.000001
		a_new = 0.9; a_old = 0.0
		b = 0
		c = 0

		f   = lambda {|a, b| (y+z)*a*a - 2*y*a + (w+x+y+z)*b*b - 2*(x+y)*b + 2*(y+z)*a*b + x + y }
		f_a = lambda {|a, b| 2*(y+z)*a - 2*y + 2*(y+z)*b }
		f_b = lambda {|a, b| 2*(w+x+y+z)*b + 2*(y+z)*a - 2*(x+y)}

		while ((a_new - a_old).abs > error)
			c += 1
			a_old = a_new
			a_new = a_old - gamma*f_a.call(a_new, b)
		end
		a_new
	end

	def self.top_matches(data, book_id, n=5)
		distances = {}
		data.keys.each_with_index do |other_book_id, i|
  		distances[other_book_id] = sim_pearson(data, book_id, other_book_id) if (book_id != other_book_id)
		end
		distances.sort_by{|k, v|v}.reverse.first(n).to_h
	end

	def self.calculate_similar_items(data, n=10)
		results = {}
		data.keys.each_with_index do |book_id, i|
			p "#{'='*20}iteration ##{i+1}#{'='*20}"
			results[book_id] = top_matches(data, book_id, n)
		end
		results
	end
 
	def self.get_recommendations(data, all_top_matches, user_id)
		total = {}
		counts = {}
		rankings = {}
		viewed_books_id = ViewedBook.find_by(:user_id => user_id).books_id.split(',').first(5)
		
		viewed_books_id.each do |vb|
			all_top_matches[vb].each do |k, v|
				next if viewed_books_id.include?(k)
				total[k] ||= 0; total[k] += v
				counts[k] ||= 0; counts[k] += 1
			end
		end
		total.keys.each do |k|
			rankings[k] = total[k]/counts[k]
		end
		rankings.sort_by{|k, v|v}.reverse.to_h.keys
	end
end

# Recommender.sim_distance(ViewedBook.book_viewed_list, '11425', '11424')
# Recommender.top_matches(ViewedBook.book_viewed_list, '11425')
