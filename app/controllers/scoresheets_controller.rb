class ScoresheetsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @scoresheets = Scoresheet.by_user(current_user.id).order("deadline DESC")
  end
  
  def new
    @scoresheet = Scoresheet.new
  end
  
  def create
    @scoresheet = Scoresheet.new(params[:scoresheet])
    @scoresheet.user_id = current_user.id
    @scoresheet.clone_from = params[:id] #for cloning
    if @scoresheet.save      
      
      #add creator as participant
      unless @scoresheet.participants.exists?(name: current_user.name)
        @scoresheet.participants.create(name: current_user.name, email: current_user.email)
      end
      
      @scoresheet.participants.each {|p| ParticipantMailer.invitation_email(p).deliver} #send invites
      redirect_to @scoresheet, notice: 'Scoresheet successfully created.'
    else
      render :new
    end
  end
  
  def edit
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:id])
  end
  
  def update
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:id])
    if @scoresheet.update_attributes(params[:scoresheet])
      redirect_to scoresheet_path(@scoresheet), notice: 'Scoresheet successfully updated.'
    else
      render :edit
    end
  end
    
  def show
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:id])
  end
    
  def destroy
  end
  
end
