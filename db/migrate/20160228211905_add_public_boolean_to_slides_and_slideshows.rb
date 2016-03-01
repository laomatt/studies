class AddPublicBooleanToSlidesAndSlideshows < ActiveRecord::Migration
  def change
    add_column :slides, :public, :boolean, :default => true
    add_column :slideshows, :public, :boolean, :default => true
  end
end
