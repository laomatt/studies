class Tagging < ActiveRecord::Base
  belongs_to :slide
  belongs_to :tag
end
