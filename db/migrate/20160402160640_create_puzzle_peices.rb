class CreatePuzzlePeices < ActiveRecord::Migration
  def change
    create_table :puzzle_peices do |t|

      t.timestamps null: false
    end
  end
end
