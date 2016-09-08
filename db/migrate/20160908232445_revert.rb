class Revert < ActiveRecord::Migration
  def change
   change_table :slides do |t|
      t.rename :first_ext_url, :ext_url
      t.rename :first_thumb_url, :thumb_url
    end
  end
end
