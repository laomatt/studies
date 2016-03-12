class AddThumbUrlToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :thumb_url, :string
  end
end
