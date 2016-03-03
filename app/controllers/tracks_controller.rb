class TracksController < ApplicationController
  load_and_authorize_resource
  def edit
    @track = @current_radio.tracks.find params[:id]
  end

  def update
    @track = @current_radio.tracks.find params[:id]
    @track.attributes = update_params
    if @track.save
      flash[:notice] = 'track tags updated!'
      render 'update'
    else
      flash[:error] = 'error updating track tags :('
      render 'error'
    end
  end

  def create
    @track = @current_radio.tracks.new create_params
    @track.filesize = params[:filesize]
    if @track.save
      ActiveSupport::Notifications.instrument 'track.created', current_user: current_user.email, radio: @current_radio.name, track: @track.file_basename
      flash[:notice] = 'track uploaded!'
      render 'create'
    else
      flash[:error] = 'error uploading track :('
      render 'error'
    end
  end

  def destroy
    @track = @current_radio.tracks.find params[:id]
    if @track.destroy
      flash[:notice] = "removed track!"
      render 'destroy'
    else
      flash[:error] = "error destroying track. try again?"
      render 'error'
    end
  end

  private
  def create_params
    params.require(:track).permit(:radio_id, :audio_file_name)
  end

  def update_params
    params.require(:track).permit(:artist, :title, :album)
  end
end
