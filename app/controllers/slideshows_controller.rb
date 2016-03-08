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

  def draw_set
    render :partial => '/slideshows/draw', :locals => params
  end

  def update_image_position
    @slideshow = Slideshow.find(params[:id])
    @slideshow.slides.find_by_id(params[:slide_id]).update_attributes(:position => params[:position])
    render :nothing => true
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
    render :json => @show.slides.map { |e| e.ext_url  }
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
