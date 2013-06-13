class Entry < ActiveRecord::Base
  belongs_to :bet
  belongs_to :participant
  
  attr_accessible :participant_id, :value, :bet_id, :winner
  
  validates_presence_of :value
  validates_numericality_of :value, :only_integer => true, :greater_than_or_equal_to => 0
  validates_uniqueness_of :bet_id, :scope => :participant_id
end