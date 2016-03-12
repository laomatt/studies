class Tagging < ActiveRecord::Base
  belongs_to :slides
  belongs_to :tag
end
