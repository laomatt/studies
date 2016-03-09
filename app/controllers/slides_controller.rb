class SlidesController < ApplicationController
  before_filter :find_slide
  skip_before_action :verify_authenticity_token, :only => :like_a_slide

  def like_a_slide
    Like.create(:slide_id => @slide.id, :user_id => current_user.id)

    render :nothing => true
  end

  private

  def find_slide
    @slide = Slide.find(params[:id])
  end
end
