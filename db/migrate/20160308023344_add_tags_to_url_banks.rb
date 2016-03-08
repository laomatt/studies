class AddTagsToUrlBanks < ActiveRecord::Migration
  def change
    add_column :url_banks, :tags, :string
  end
end
