class CreateUrlBanks < ActiveRecord::Migration
  def change
    create_table :url_banks do |t|
      t.string :url
      t.timestamps null: false
    end
  end
end
