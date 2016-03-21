class Slide < ActiveRecord::Base
  belongs_to :slideshow
  belongs_to :user
  has_many :likes
  has_many :list_slides
  has_many :taggings
end
