class AddAScoresTable < ActiveRecord::Migration
    def up
      create_table :scores do |t|
        t.integer :user_id
        t.integer :beverage
        t.string  :activity_date
        t.integer :total_score

      end
    end

    def down
      drop_table :scores
    end
end
