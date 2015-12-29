class Profile < ActiveRecord::Base
  self.primary_key = 'user_id'

  belongs_to :user
end