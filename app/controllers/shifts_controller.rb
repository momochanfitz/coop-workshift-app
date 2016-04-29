require 'chronic'
require 'pp'

class ShiftsController < ApplicationController
  #before_action :set_shift, only: [:show, :edit, :update, :destroy]
  skip_before_filter :set_current_user

  # GET /shifts
  # GET /shifts.json
  def index
    @shifts = Shift.all
    @serializedShifts = json_shifts(@shifts)
    @allUsers = User.all.to_json
  end
  
  def change_users
    params[:shift_ids].zip(params[:user_ids]).each do |shift_id, user_id|
      shift = Shift.find_by_id(shift_id)
      user = User.find_by_id(user_id)
      if user and shift
        shift.user = user
        shift.save()
      else
        render :text => "Error saving shifts", :status => 500, :content_type => 'text/html'
        return
      end
    end
    render :text => "Successfully saved shifts", :status => 200, :content_type => 'text/html'
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
  end

  # GET /shifts/new
  def new
  end

  # GET /shifts/1/edit
  def edit
  end


  # PATCH/PUT /shifts/1
  # PATCH/PUT /shifts/1.json
  def update
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift = Shift.find_by_id(params[:id])
    @shift.destroy
    respond_to do |format|
      format.html { redirect_to shifts_url, notice: 'Shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    #def set_shift
    #  @shift = Shift.find(params[:id])
    #end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_params
      params.require(:shift).permit(:start_time, :end_time, :metashift_id)
    end
    
    #Keys: shift, user, start_time, end_time, description
    def json_shifts(instances)
      lst = []
      instances.each do |shift|
        lst << shift.full_json
      end
      lst
    end 
end
