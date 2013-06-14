class AddConsolationToScoresheets < ActiveRecord::Migration
  def change
    add_column :scoresheets, :consolation, :boolean, default: false, null: false
    add_column :scoresheets, :consolation_points, :decimal
  end
end
