class List < ActiveRecord::Base
  has_many :list_slides
  belongs_to :user
end
