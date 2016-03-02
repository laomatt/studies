class SlideshowsController < ApplicationController
  def show
    @show = Slideshow.find(params[:id])
    @images = @show.slides

  end

  def edit
    @slideshow = Slideshow.find(params[:id])
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
