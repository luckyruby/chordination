class CreateParticipants < ActiveRecord::Migration
  def change
    create_table(:participants) do |t|
      t.integer :scoresheet_id, null: false
      t.integer :position
      t.string :name, null: false
      t.string :email, null: false
      t.string :key, null: false
      t.boolean :accepted, null: false, default: false
      t.boolean :declined, null: false, default: false
      t.timestamps
    end
    add_index :participants, [:scoresheet_id, :email], :unique => true
    add_index :participants, [:scoresheet_id, :name], :unique => true
    add_index :participants, :key, :unique => true
  end
end
