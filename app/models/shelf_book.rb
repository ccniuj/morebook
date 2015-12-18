class ShelfBook < ActiveRecord::Base
  belongs_to :shelf
  belongs_to :book
  belongs_to :user
end
