class AddNsfwToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :nsfw, :boolean, :default => false
  end
end
