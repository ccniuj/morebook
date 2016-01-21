namespace :shelf do
  desc "generate fake shelf members"
  task fake: :environment do
  	p "Fake shelf members..."
  	Shelf.fake_data
  	p "Fake shelf members...done."
  end
end
