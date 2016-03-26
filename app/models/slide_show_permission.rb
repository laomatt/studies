class SlideShowPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :slideshow
end
