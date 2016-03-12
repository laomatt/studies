class RemoveTagsFromSlides < ActiveRecord::Migration
  def change
    remove_column :slides, :tags
  end
end
