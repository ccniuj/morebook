namespace :recommendation do
  desc "generate fake viewed_books data"
  task fake: :environment do
  	p "Fake users data..."
  	User.fake_data
  	p "Fake users data...done."
  	p "Fake viewed_books data..."
  	ViewedBook.fake_data
  	p "Fake viewed_books data...done."
  end

  desc "calculate top_matches for each book"
  task calculate: :environment do
  	p "Calculate top_matches..."
  	Redis.new.set('all_top_matches', 
  			Recommender.calculate_similar_items(ViewedBook.book_viewed_list).to_json)
  	p "Calculate top_matches...done."
  end
end
