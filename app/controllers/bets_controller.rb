class BetsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @scoresheet = Scoresheet.find(params[:scoresheet_id])
    @bet = Bet.new
  end
  
  def create
    @scoresheet = Scoresheet.find(params[:scoresheet_id])
    @bet = Bet.new(params[:bet])
    @bet.scoresheet_id = params[:scoresheet_id]
    if @bet.save
      redirect_to @scoresheet, notice: 'Bet was successfully created.'
    else
      render :new
    end
  end
  
  def edit
    @scoresheet = Scoresheet.find(params[:scoresheet_id])
    @bet = Bet.find(params[:id])
  end
  
  def update
    @scoresheet = Scoresheet.find(params[:scoresheet_id])
    @bet = Bet.find(params[:id])
    if ["move_lower", "move_higher"].include? params[:method]
      @bet.send params[:method]
      redirect_to @scoresheet
    else
      if @bet.update_attributes(params[:bet])
        redirect_to @scoresheet, notice: 'Bet was successfully updated.'
      else
        render :edit
      end
    end
  end
  
  def destroy
    @scoresheet = Scoresheet.find(params[:id])
    @bet = Bet.find(params[:id])
    @bet.destroy
    redirect_to @scoresheet
  end
  
  def results
    @scoresheet = Scoresheet.find(params[:id])
    @scoresheet.build_result_fields
  end
  
  def save_results
    @scoresheet = Scoresheet.find(params[:id])
    if @scoresheet.update_attributes(params[:scoresheet])
      redirect_to @scoresheet, notice: 'Results have been saved.'
    else
      render :results
    end
  end
  
end
