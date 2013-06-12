class CreateEntries < ActiveRecord::Migration
  def change
    create_table(:entries) do |t|
      t.integer :participant_id, null: false
      t.integer :bet_id, null: false
      t.string :value, null: false
      t.string :winner
      t.timestamps
    end
    add_index :entries, [:participant_id, :bet_id], unique: true
  end
end
