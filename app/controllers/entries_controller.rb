class EntriesController < ApplicationController
  before_filter :validate_key
  before_filter :check_status
  before_filter :check_expiration, :except => [:show, :message]
  
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
      @message = Message.new
      @results = @scoresheet.results_in?
      
      @entries = @scoresheet.compile_entries(@results)      
      if @scoresheet.expired? && @results
        @differentials = @scoresheet.compile_differentials
        @consolation = @scoresheet.compile_consolation(@differentials)
        @winners = @scoresheet.compile_winners(@differentials, @entries, @consolation)
        @standings = @scoresheet.compile_standings(@winners)
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
  
  def message
    @message = Message.new(params[:message])
    @message.scoresheet_id = @participant.scoresheet_id
    @message.participant_id = @participant.id
    @message.sender = @participant.name
    if @message.save
      redirect_to "/entries/#{@participant.key}", notice: 'Message successfully posted.'
    else
      render :show
    end
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