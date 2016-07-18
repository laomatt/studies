class AddFileProcessingToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :file_processing, :boolean, null: false, default: false
    add_column :slides, :file_tmp, :string
  end
end
