class RemoveThumbUrlAndExtUrlFrom < ActiveRecord::Migration
  def change
    rename_column :slides, :thumb_url, :first_thumb_url
    rename_column :slides, :exl_url, :first_ext_url
  end
end
