class CreateMessages < ActiveRecord::Migration
  def change
    create_table(:messages) do |t|
      t.integer :scoresheet_id, null: false
      t.integer :participant_id, null: false
      t.string :sender, null: false
      t.text :content, null: false
      t.timestamps
    end
  end
end
