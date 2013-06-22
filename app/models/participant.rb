class Participant < ActiveRecord::Base
  acts_as_list :scope => :scoresheet
  belongs_to :scoresheet, :inverse_of => :participants
  has_many :bets, :through => :scoresheet, order: 'bets.position'
  has_many :entries, :dependent => :destroy, autosave: true, :include => :bet, order: 'bets.position'
  has_many :messages, autosave: true, order: 'messages.created_at'
  
  scope :accepted, where(accepted: true)
  scope :declined, where(declined: true)
  
  attr_accessible :name, :email, :entries_attributes, :accepted, :declined
  
  accepts_nested_attributes_for :entries
  
  validates :name, :email, :scoresheet, :key, presence: true
  validates :email, uniqueness: {:scope => :scoresheet_id}
  validates :name, uniqueness: {:scope => :scoresheet_id}
  validates :key, uniqueness: true
  
  #assign unique random key
  before_validation(:on => :create) do
    self.key = loop do
      random_key = SecureRandom.urlsafe_base64
      break random_key unless Participant.where(key: random_key).exists?
    end
  end
    
  def build_entry_fields
    self.bets.each do |b|
      self.entries.build(bet_id: b.id) unless self.entries.map(&:bet_id).include?(b.id)
    end
  end
    
end