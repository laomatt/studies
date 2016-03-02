class SlideshowsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :update_image_position
  def show
    @show = Slideshow.find(params[:id])
    @images = @show.slides

  end

  def edit
    @slideshow = Slideshow.find(params[:id])
    @images = @slideshow.slides.order(:position)
  end

  def update_image_position
    @slideshow = Slideshow.find(params[:id])
    @slideshow.slides.find_by_id(params[:slide_id]).update_attributes(:position => params[:position])
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
end
