class BookTag < ActiveRecord::Base
  belongs_to :book
  belongs_to :tag
end