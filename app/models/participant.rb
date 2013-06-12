class Participant < ActiveRecord::Base
  acts_as_list
  belongs_to :scoresheet
  has_many :bets, :through => :scoresheet
  has_many :entries, :dependent => :destroy, autosave: true
  
  scope :accepted, where(accepted: true)
  scope :declined, where(declined: true)
  
  attr_accessible :name, :email, :entries_attributes, :accepted, :declined
  
  accepts_nested_attributes_for :entries
  
  validates_presence_of :name, :email, :scoresheet_id
  validates_uniqueness_of :email, :scope => :scoresheet_id
  validates_uniqueness_of :name, :scope => :scoresheet_id
  
  
  #assign unique random key
  before_validation(:on => :create) do
    self.key = loop do
      random_key = SecureRandom.urlsafe_base64
      break random_key unless Participant.where(key: random_key).exists?
    end
  end
    
  def build_entry_fields
    self.bets.order("position").each do |b|
      self.entries.build(bet_id: b.id) unless self.entries.map(&:bet_id).include?(b.id)
    end
  end
    
end