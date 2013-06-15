class Scoresheet < ActiveRecord::Base
  belongs_to :user
  has_many :bets, :dependent => :destroy, autosave: true, :inverse_of => :scoresheet
  has_many :participants, :dependent => :destroy, autosave: true, :inverse_of => :scoresheet
  
  attr_accessible :name, :deadline, :message, :bets_attributes, :consolation, :consolation_points
  
  accepts_nested_attributes_for :bets
  
  scope :by_user, lambda { |id| where(user_id: id) }
  
  validates_presence_of :user_id, :name, :deadline
  validates_numericality_of :user_id
  validates_uniqueness_of :name, :scope => :user_id
  
  def participant_count
    self.participants.length
  end
  
  def expired?
    self.deadline < Time.now
  end
  
  def results_in?
    !self.bets.map(&:value).any? {|i| i.nil? }
  end
  
  def build_result_fields
    self.bets.each {|b| self.bets.build unless self.bets.map(&:id).include?(b.id)}
  end
  
  def clone_from(id)
    original = Scoresheet.by_user(self.user_id).find(id)
    original.bets.order("position").each do |b|
      self.bets.build(name: b.name, bet_type: b.bet_type, choices: b.choices, points: b.points)
    end
    original.participants.order("position").each do |p|
      self.participants.build(name: p.name, email: p.email)
    end
  end

end