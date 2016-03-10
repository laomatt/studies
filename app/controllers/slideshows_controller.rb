class SlideshowsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :update_image_position
  before_action :authenticate_user!, :except => [:show, :draw_set, :draw_set_random, :draw, :get_image, :get_images_from_show, :get_images_from_show_random]
  def show
    @show = Slideshow.find(params[:id])
    @images = @show.slides
  end

  def edit
    @slideshow = Slideshow.find(params[:id])
    @images = @slideshow.slides.order(:position)
  end

  def draw_set
    render :partial => '/slideshows/draw', :locals => params
  end

  def draw_set_random
    num_poses = params[:num]
    length = params[:pose_l]
    render :partial => '/slideshows/draw_random', :locals => {:pose_length => length, :pose_number => num_poses}
  end

  def update_image_position
    @slideshow = Slideshow.find(params[:id])
    @slideshow.slides.find_by_id(params[:slide_id]).update_attributes(:position => params[:position])
    render :nothing => true
  end

  def find_slide
    url = params[:url]
    slide = Slide.find_by_ext_url(url)
    if Like.exists?(:user_id => current_user.id, :slide_id => slide.id)
      slide = {:already_liked => true}
    end
    render :json => slide
  end

  def update_slide_show
    @show = Slideshow.find(params[:id])
    @show.update_attributes(slideshow_params)
    render :nothing => true
  end

  def draw
    @show = Slideshow.find(params[:id])
    @images = @show.slides.shuffle
    @num_sets = params[:num_sets]
    @pose_length = params[:pose_length]
    @pose_number = params[:pose_number]
    @image_pause = params[:image_pause]
    @set_pause = params[:set_pause]
  end

  def get_images_from_show
    @show = Slideshow.find(params[:id])
    images_spent = params[:already].split(',')
    idx = params[:slin]
    if params[:random]
      @slide = @show.slides.select{ |e| !images_spent.include?(e.id.to_s)}.sample
    else
      @slide = @show.slides.order(:position)[idx]
    end

    render :json => @slide
  end

  def get_images_from_show_random
    images_spent = params[:already].split(',').map { |e| e.to_i }
    if images_spent.empty?
      images_spent = [1,2]
    end
    @slide = Slide.where('id not in (?)', images_spent).sample
    render :json => @slide
  end


  def get_image
    @show = Slideshow.find(params[:id])
    @images = @show.slides.shuffle
    if params[:n]
      image = @images[params[:n].to_i]
      render :json => {:image => image, :total => @images.count}
    else
      render :json => @images
    end
  end

  private

  def slideshow_params
    params.require(:info).permit(:title)
  end

end
