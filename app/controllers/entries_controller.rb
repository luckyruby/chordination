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
      @scoresheet = @participant.scoresheet
      @bets = @scoresheet.bets.order("position")
      @participants = @scoresheet.participants.accepted.order("position")
      @entries = {}
      @differentials = {}
      @winners = {}
      @standings = {}
      @results = @scoresheet.results_in?
      
      #initialize hashes by bet id
      @bets.each do |b|
        @entries[b.id] = {}
        
        if @scoresheet.expired? && @results
          @differentials[b.id] = {}
          @winners[b.id] = {}
        end
      end
      
      #populate entries and differentials hash
      @participants.each do |p|
        p.entries.each do |e|
          bet_id = e.bet.id
          entry = e.value.to_i
          result = e.bet.value.to_i if e.bet.value.present?
          
          if e.bet.bet_type == 'winner'
            @entries[bet_id][p.name] = "#{e.winner} by #{e.value}"
            if result
              @differentials[e.bet.id][p.name] = if e.bet.winner == e.winner
                                      (result - entry).abs
                                    else
                                      entry + result
                                    end
            end
          else
            @entries[bet_id][p.name] = e.value
            @differentials[e.bet.id][p.name] = (result - entry).abs if result
          end
        end
      end
      
      #add results to entries hash
      if @results
        @bets.each do |b|
          @entries[b.id]['result'] = if b.bet_type == "winner"
                                        "#{b.winner} by #{b.value}"
                                      else
                                        b.value
                                      end
        end
      end
      
      if @scoresheet.expired? && @results
        
        #calculate consolation differential
        if @scoresheet.consolation?
          @consolation = {}
          @participants.each do |p|
            @consolation[p.name] = 0
            non_winner_bets = @bets.select {|b| b.bet_type != 'winner'}
            winner_bets = @bets.select{|b| b.bet_type == 'winner'}
            non_winner_bets.each do |b|
              @consolation[p.name] += @differentials[b.id][p.name]
            end
            winner_bets.each do |b|
              @consolation[p.name] += @differentials[b.id][p.name]
              @consolation[p.name] -= 3 if b.winner == p.entries.detect {|e| e.bet_id == b.id}.try(:winner) #3 pt discount if winner picked correctly
            end
          end
        end
        
        #determine winners of each bet
        @bets.each do |b|
          lowest_diff = @differentials[b.id].values.sort.first
          @winners[b.id] = @differentials[b.id].select {|k,v| v == lowest_diff}.keys
        end
        if @scoresheet.consolation?
          lowest_consolation = @consolation.values.sort.first
          @winners['consolation'] = @consolation.select {|k,v| v == lowest_consolation}.keys
        end
        
        #determine standings of each participant
        participants_count = @participants.length
        @participants.each do |p|
          @standings[p.name] = {}
          @bets.each do |b|
            winner_count = @winners[b.id].length
            loser_count = (participants_count - winner_count)
            @standings[p.name][b.id] =  if @winners[b.id].include?(p.name)
                                        loser_count * b.points.to_f / winner_count.to_f
                                      else
                                        b.points*-1
                                      end
          end
          if @scoresheet.consolation?
            consolation_winner_count = @winners['consolation'].length
            consolation_loser_count = (participants_count - consolation_winner_count)        
            @standings[p.name]['consolation'] = if @winners['consolation'].include?(p.name)
                                                consolation_loser_count * @scoresheet.consolation_points / consolation_winner_count
                                              else
                                                @scoresheet.consolation_points*-1
                                              end
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