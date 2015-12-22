class UserShelf < ActiveRecord::Base
  belongs_to :user
  belongs_to :shelf
end