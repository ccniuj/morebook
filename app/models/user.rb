class User < ActiveRecord::Base
  has_many :notes
  has_many :comments
  has_many :rates
  has_many :shelf_books
  has_many :user_shelves
  has_many :shelves, through: :user_shelves
  has_one :star
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
