class SlidesController < ApplicationController
  before_filter :find_slide
  skip_before_action :verify_authenticity_token, :only => [:like_a_slide, :destroy_this_slide, :unlike_slide]

  def like_a_slide
    Like.create(:slide_id => @slide.id, :user_id => current_user.id)

    render :nothing => true
  end

  def update
    @slide.update_attributes(slide_params)
    render :json => @slide
  end

  def destroy_this_slide
    @slide.likes.each do |like|
      like.delete
    end

    if @slide.on_s3?
      obj_key = "#{current_user.email}/#{@slide.title}"
      obj = S3_BUCKET.object(obj_key)
      obj.delete
    end

    slide = @slide.delete
    render :json => slide
  end

  def unlike_slide
    like = Like.where('slide_id = ? and user_id = ?',@slide.id,current_user.id).first
    Like.delete(like.id)

    render :nothing => true

  end

  def get_partial
    info = Hash[@slide.attributes.map{ |k, v| [k.to_sym, v] }]
    if params[:type] == 'inspect'
      render :partial => '/slideshows/slidedisplay', :locals => info
    elsif params[:type] == 'edit'
      render :partial => '/slideshows/slideedit', :locals => info
    elsif params[:type] == 'delete'
      render :partial => '/slideshows/deleteslide', :locals => info
    end
  end

  private

  def find_slide
    @slide = Slide.find(params[:id])
  end

  def slide_params
    params.require(:slide_info).permit(:title,:ext_url, :tags)
  end
end
