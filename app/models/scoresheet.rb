class Scoresheet < ActiveRecord::Base
  belongs_to :user
  has_many :bets
  has_many :participants
  
  attr_accessible :name, :deadline, :message, :bets_attributes
  
  accepts_nested_attributes_for :bets
  
  scope :by_user, lambda { |user| where(user_id: user.id) }
  
  validates_presence_of :user_id, :name, :deadline
  validates_numericality_of :user_id
  validates_uniqueness_of :name, :scope => :user_id
  
  after_create :add_creator_as_participant
  
  def participant_count
    self.participants.length
  end
  
  def expired?
    self.deadline < Time.now
  end
  
  def build_result_fields
    self.bets.order("position").each do |b|
      self.bets.build unless self.bets.map(&:id).include?(b.id)
    end
  end
  
  private
  def add_creator_as_participant
    creator = self.participants.create(name: self.user.name, email: self.user.email, accepted: true)
    ParticipantMailer.invitation_email(creator).deliver
  end

end