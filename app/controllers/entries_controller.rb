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
      @participants.each do |p|
        p.entries.each do |e|
          if e.bet.bet_type == 'winner'
            @entries["#{e.bet.id}:#{p.id}"] = "#{e.winner} by #{e.value}"
          else
            @entries["#{e.bet.id}:#{p.id}"] = e.value
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