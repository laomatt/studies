class ListSlide < ActiveRecord::Base
  belongs_to :slide
  belongs_to :list
end
