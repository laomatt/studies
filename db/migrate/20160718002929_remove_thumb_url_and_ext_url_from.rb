class RemoveThumbUrlAndExtUrlFrom < ActiveRecord::Migration
  def change
   change_table :slides do |t|
      t.rename :ext_url, :first_ext_url
      t.rename :thumb_url, :first_thumb_url
    end
    # rename_column :slides, :exl_url, :first_ext_url
    # rename_column :slides, :thumb_url, :first_thumb_url
  end
end
