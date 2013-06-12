class Bet < ActiveRecord::Base
  acts_as_list :scope => :scoresheet
  belongs_to :scoresheet
  has_many :entries
  
  attr_accessible :name, :bet_type, :choices, :result, :points
  
  validates_presence_of :name, :scoresheet_id
  
end