class Tag < ActiveRecord::Base
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags
end