class AddPublicDeletedToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :deleted, :boolean, :default => false
  end
end
