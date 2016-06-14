class CreatePuzzles < ActiveRecord::Migration
  def change
    create_table :puzzles do |t|

      t.timestamps null: false
    end
  end
end
