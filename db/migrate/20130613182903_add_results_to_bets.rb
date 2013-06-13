class AddResultsToBets < ActiveRecord::Migration
  def up
    add_column :bets, :value, :string
    add_column :bets, :winner, :string
    remove_column :bets, :result
  end
  
  def down
    add_column :bets, :result, :string
    remove_column :bets, :value
    remove_column :bets, :winner
  end
end
