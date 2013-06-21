class ParticipantsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.new
  end
  
  def create
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.new(params[:participant])
    @participant.scoresheet_id = params[:scoresheet_id]
    if @participant.save
      ParticipantMailer.invitation_email(@participant).deliver
      redirect_to @scoresheet, notice: 'Successfully added participant.'
    else
      render :new
    end    
  end
  
  def edit
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.find(params[:id])
  end
  
  def update
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.find(params[:id])
    if ["move_lower", "move_higher"].include? params[:method]
      @participant.send params[:method]
      redirect_to scoresheet_path(params[:scoresheet_id])
    else
      if @participant.update_attributes(params[:participant])
        redirect_to @scoresheet, notice: 'Successfully updated participant.'
      else
        render :edit
      end
    end
  end
  
  def destroy
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.find(params[:id])
    @participant.destroy
    redirect_to @scoresheet, notice: "#{@participant.name} has successfully been removed."
  end
  
  def reinvite
    @scoresheet = Scoresheet.by_user(current_user.id).find(params[:scoresheet_id])
    @participant = Participant.find(params[:id])
    @participant.update_attributes(declined: false) if @participant.declined? #reset declined flag
    ParticipantMailer.invitation_email(@participant).deliver
    redirect_to @scoresheet, notice: "Successfully re-invited #{@participant.email}."
  end
  
  def sort
    params[:participant].each_with_index do |id, index|
      Participant.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

end
