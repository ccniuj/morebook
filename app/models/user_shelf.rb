class UserShelf < ActiveRecord::Base
  belongs_to :User
  belongs_to :Shelf
end