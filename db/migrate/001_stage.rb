class Stage < ActiveRecord::Migration

    def change
        create_table :stages do |t|
            t.integer :order
            t.text :clue_type
            t.text :content
            t.timestamps
        end

        create_table :hunters do |t|
            t.text :name
            t.text :phone
            t.integer :stage_id
            t.timestamps
        end
    end

end