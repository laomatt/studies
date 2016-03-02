class AddPositionToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :position, :integer, :default => 0, :null => false
  end
end
