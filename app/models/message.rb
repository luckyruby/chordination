class Message < ActiveRecord::Base
  belongs_to :scoresheet
  belongs_to :participant
  
  attr_accessible :content
  
end