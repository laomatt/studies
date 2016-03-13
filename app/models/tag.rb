class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :slides, :through => :taggings
end
