class AddMessageToScoresheets < ActiveRecord::Migration
  def change
    add_column :scoresheets, :message, :text
  end
end
