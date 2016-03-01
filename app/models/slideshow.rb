class Slideshow < ActiveRecord::Base
  has_many :slides
  belongs_to :user
end
