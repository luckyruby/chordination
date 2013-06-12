class CreateBets < ActiveRecord::Migration
  def change
    create_table(:bets) do |t|
      t.integer :scoresheet_id, null: false
      t.integer :position
      t.string :name, null: false
      t.string :bet_type, null: false
      t.string :choices
      t.string :result
      t.timestamps
    end
    add_index :bets, [:scoresheet_id, :name], :unique => true
  end
end
