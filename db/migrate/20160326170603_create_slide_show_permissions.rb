class CreateSlideShowPermissions < ActiveRecord::Migration
  def change
    create_table :slide_show_permissions do |t|
      t.references :user
      t.references :slideshow

      t.timestamps null: false
    end
  end
end
