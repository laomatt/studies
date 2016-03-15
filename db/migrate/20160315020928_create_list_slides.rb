class CreateListSlides < ActiveRecord::Migration
  def change
    create_table :list_slides do |t|
      t.references :slide
      t.references :list

      t.timestamps null: false
    end
  end
end
