class AddUserIdToSlides < ActiveRecord::Migration
  def change
    add_column :slides, :user_id, :integer
  end
end
