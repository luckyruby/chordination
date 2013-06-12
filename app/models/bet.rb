class Bet < ActiveRecord::Base
  acts_as_list
  belongs_to :scoresheet
  has_many :entries
  
  attr_accessible :name, :bet_type, :choices, :result
  
  validates_presence_of :name, :scoresheet_id
  
end