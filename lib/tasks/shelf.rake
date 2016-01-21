namespace :shelf do
  desc "generate fake shelf members"
  task fake_member: :environment do
  	p "Fake shelf members..."
  	Shelf.fake_member
  	p "Fake shelf members...done."
  end
end
