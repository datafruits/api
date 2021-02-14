class Api::UserFollowsController < ApplicationController
  before_action :current_radio_required

  def create
    @user_follow = UserFollow.create user_follow_params
  end

  def destroy
  end

  private
  def user_follow_params
    params.require(:user_follow).permit(:user_id, :followee_id)
  end
end
