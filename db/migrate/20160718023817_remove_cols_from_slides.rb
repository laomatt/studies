class RemoveColsFromSlides < ActiveRecord::Migration
  def change
    remove_column :slides, :ext_url
    remove_column :slides, :thumb_url
  end
end
