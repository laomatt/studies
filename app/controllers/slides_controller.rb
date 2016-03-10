class SlidesController < ApplicationController
  before_filter :find_slide
  skip_before_action :verify_authenticity_token, :only => :like_a_slide

  def like_a_slide
    Like.create(:slide_id => @slide.id, :user_id => current_user.id)

    render :nothing => true
  end

  def get_partial
    info = Hash[@slide.attributes.map{ |k, v| [k.to_sym, v] }]
    if params[:type] == 'inspect'
      render :partial => '/slideshows/slidedisplay', :locals => info
    elsif params[:type] == 'edit'
      render :partial => '/slideshows/slideedit', :locals => info
    end
  end

  private

  def find_slide
    @slide = Slide.find(params[:id])
  end
end
