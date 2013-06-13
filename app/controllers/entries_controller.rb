class EntriesController < ApplicationController
  before_filter :validate_key
  before_filter :check_status
  before_filter :check_expiration, :except => [:show]
  
  def new
  end
  
  def edit
    @participant.build_entry_fields
  end
  
  def update
    if @participant.update_attributes(params[:participant])
      redirect_to "/entries/#{@participant.key}", notice: 'Your entries have been saved.'
    else
      render :edit
    end
  end
  
  def show
    if @participant.accepted?
      @bets = @participant.scoresheet.bets.order("position")
      @participants = @participant.scoresheet.participants.accepted.order("position")
      @entries = {}
      @differentials = {}
      @winners = {}
      @standings = {}
      
      #initialize hashes by bet id
      @bets.each do |b|
        @entries[b.id] = {}
        @differentials[b.id] = {}
        @winners[b.id] = {}
      end
      
      #populate entries and differentials hash
      @participants.each do |p|
        p.entries.each do |e|
          bet_id = e.bet.id
          entry = e.value.to_i
          result = e.bet.value.to_i if e.bet.value.present?
          
          if e.bet.bet_type == 'winner'
            @entries[bet_id][p.id] = "#{e.winner} by #{e.value}"
            if result
              @differentials[e.bet.id][p.id] = if e.bet.winner == e.winner
                                      (result - entry).abs
                                    else
                                      entry + result
                                    end
            end
          else
            @entries[bet_id][p.id] = e.value
            @differentials[e.bet.id][p.id] = (result - entry).abs if result
          end
        end
      end
      
      #determine winners of each bet
      @bets.each do |b|
        lowest_diff = @differentials[b.id].values.sort.first
        @winners[b.id] = @differentials[b.id].select {|k,v| v == lowest_diff}.keys
      end
      
      #determine standings of each participant
      @participants.each do |p|
        @standings[p.id] = {}
        @bets.each do |b|
          winner_count = @winners[b.id].length
          loser_count = (@participants.length - winner_count)
          @standings[p.id][b.id] =  if @winners[b.id].include?(p.id)
                                      loser_count * b.points.to_f / winner_count.to_f
                                    else
                                      b.points*-1
                                    end
        end
      end
      
    else
      redirect_to "/entries/#{@participant.key}/new"
    end
  end
  
  def accept
    @participant.accepted = true
    @participant.save
    redirect_to "/entries/#{@participant.key}/edit"
  end
  
  def decline
    @participant.accepted = false
    @participant.declined = true
    @participant.save
    render text: 'You have successfully declined this invite.'
  end
    
  private
  
  def validate_key
    @participant = Participant.find_by_key(params[:key])
    render text: 'Invalid Participant' unless @participant
  end
  
  def check_expiration
    render text: 'Sorry, the deadline for this bet has passed!' if @participant.scoresheet.expired?
  end
  
  def check_status
    render text: 'You have previously declined this invite.' if @participant.declined?
  end
    
end