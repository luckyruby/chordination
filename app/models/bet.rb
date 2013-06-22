class Bet < ActiveRecord::Base
  acts_as_list :scope => :scoresheet
  belongs_to :scoresheet, :inverse_of => :bets
  has_many :entries
  
  #value & winner are used to store the result of the bet
  attr_accessible :name, :bet_type, :choices, :points, :value, :winner
  
  validates :name, :bet_type, :scoresheet, presence: true
  validates :choices, presence: { message: "can't be blank for winner bet type" }, :if => :winner_bet_type?
  validates :name, uniqueness: {:scope => :scoresheet_id}
  validate :multiple_choices, :if => proc { self.choices.present? && self.winner_bet_type? }
  
  def winner_bet_type?
    bet_type == 'winner'
  end
  
  private
  def multiple_choices
    choice_count = self.choices.split(",").length
    errors.add(:choices, "must contain more than one choice") unless choice_count > 1
  end
  
end