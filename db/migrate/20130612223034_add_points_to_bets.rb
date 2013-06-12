class AddPointsToBets < ActiveRecord::Migration
  def change
    add_column :bets, :points, :integer, null: false, default: 5
  end
end
