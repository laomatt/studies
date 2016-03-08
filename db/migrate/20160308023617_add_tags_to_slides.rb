class AddTagsToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :tags, :string
  end
end
