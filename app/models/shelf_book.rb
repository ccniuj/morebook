class ShelfBook < ActiveRecord::Base
  belongs_to :shelf
  belongs_to :book
end
