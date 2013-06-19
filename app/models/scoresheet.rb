class Scoresheet < ActiveRecord::Base
  belongs_to :user
  has_many :bets, :dependent => :destroy, autosave: true, :inverse_of => :scoresheet, order: 'bets.position'
  has_many :participants, :dependent => :destroy, autosave: true, :inverse_of => :scoresheet, order: 'participants.position'
  has_many :messages, :dependent => :destroy, autosave: true, order: 'messages.created_at'
  
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
  
  def compile_entries(results=nil)
    #initialize hash by bet id
    entries = {}
    self.bets.each do |b|
      entries[b.id] = {}
      
      #add results if results are in
      entries[b.id]['result'] = (b.bet_type == "winner" ? "#{b.winner} by #{b.value}" : b.value) if results
    end
    
    #populate
    self.participants.accepted.each do |p|
      p.entries.each do |e|      
        entries[e.bet_id][p.name] = (e.bet.bet_type == 'winner' ? "#{e.winner} by #{e.value}" : e.value)
      end
    end
    
    entries    
  end
  
  def compile_differentials
    #initialize hash by bet_id
    differentials = {}
    self.bets.each {|b| differentials[b.id] = {}}
    
    #populate
    self.participants.accepted.each do |p|
      p.entries.each do |e|
        entry = e.value.to_i
        result = e.bet.value.to_i if e.bet.value.present?
        if result
          differentials[e.bet_id][p.name] = if e.bet.bet_type == 'winner' && e.bet.winner != e.winner
            #if you picked the wrong winner
            entry + result
          else
            (result - entry).abs
          end
        end
      end
    end
    
    differentials    
  end
  
  def compile_consolation(differentials={})
    consolation = {}
    if self.consolation?
      self.participants.accepted.each do |p|
        consolation[p.name] = 0
        non_winner_bet_types = self.bets.select {|b| b.bet_type != 'winner'}
        winner_bet_types = self.bets.select{|b| b.bet_type == 'winner'}
        
        non_winner_bet_types.each do |b|
          consolation[p.name] += differentials[b.id][p.name]
        end
        
        winner_bet_types.each do |b|
          consolation[p.name] += differentials[b.id][p.name]
          consolation[p.name] -= 3 if b.winner == p.entries.detect {|e| e.bet_id == b.id}.try(:winner) #3 pt discount if winner picked correctly
        end
      end
    end
    
    consolation
  end
  
  def compile_winners(differentials, entries, consolation={})
    def tiebreaker(bet, entries, winners)
      tiebreak = []
      winners.each do |w|
        if entries[bet.id][w].split(" by ").first == bet.winner
          tiebreak << w
        end
      end
      
      tiebreak
    end
    
    winners = {}
    self.bets.each do |b|
      lowest_diff = differentials[b.id].values.sort.first
      bet_winner = differentials[b.id].select {|k,v| v == lowest_diff}.keys
      if b.bet_type == 'winner' && bet_winner.length > 1 #break the tie by who picked correct winner
        winners[b.id] = tiebreaker(b, entries, bet_winner)
      else
        winners[b.id] = bet_winner
      end
    end
    
    #add consolation winner
    if self.consolation? && consolation.present?
      lowest_consolation = consolation.values.sort.first
      winners['consolation'] = consolation.select {|k,v| v == lowest_consolation}.keys
    end
    
    winners
  end
  
  def compile_standings(winners)
    standings = {}
    participants = self.participants.accepted
    participants_count = participants.length
    
    #populate
    participants.each do |p|
      standings[p.name] = {}    
      self.bets.each do |b|
        winner_count = winners[b.id].length
        loser_count = (participants_count - winner_count)
        standings[p.name][b.id] = (winners[b.id].include?(p.name) ? loser_count * b.points.to_f / winner_count.to_f : b.points*-1)
      end
      
      #add consolation standing
      if self.consolation?
        consolation_winner_count = winners['consolation'].length
        consolation_loser_count = (participants_count - consolation_winner_count)        
        standings[p.name]['consolation'] = (winners['consolation'].include?(p.name) ? consolation_loser_count * self.consolation_points / consolation_winner_count : self.consolation_points*-1)
      end
    end
    
    standings
  end

end