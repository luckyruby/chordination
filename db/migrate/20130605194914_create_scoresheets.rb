class CreateScoresheets < ActiveRecord::Migration
  def change
    create_table(:scoresheets) do |t|
      t.integer :user_id, null: false
      t.string :name, null: false
      t.datetime :deadline, null: false
      t.timestamps
    end
    add_index :scoresheets, [:user_id, :name], :unique => true
  end
end
