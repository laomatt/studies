class Slideshow < ActiveRecord::Base
  has_many :slides
  has_many :slide_show_permissions
  belongs_to :user
end
