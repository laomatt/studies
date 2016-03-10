class AddOnS3ToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :on_s3, :boolean, :default => false
  end
end
