class Bet < ActiveRecord::Base
  acts_as_list :scope => :scoresheet
  belongs_to :scoresheet
  has_many :entries
  
  #value & winner are used to store the result of the bet
  attr_accessible :name, :bet_type, :choices, :points, :value, :winner
  
  validates_presence_of :name, :scoresheet_id
  
end