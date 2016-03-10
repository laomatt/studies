class Slide < ActiveRecord::Base
  belongs_to :slideshow
  belongs_to :user
  has_many :likes
end
