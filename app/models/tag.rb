class Tag < ActiveRecord::Base
  has_many :books
end