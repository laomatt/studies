class SlideshowsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:update_image_position, :mark_all_slides_nsfw]
  before_action :authenticate_user!, :except => [:show, :draw_set, :draw_set_random, :draw, :get_image, :get_images_from_show, :get_images_from_show_random, :get_image_slide_show, :get_image_slide_show_tags]
  def show
    @show = Slideshow.find(params[:id])
    if @show.public || SlideShowPermission.exists?(:slideshow_id => @show.id, :user_id => current_user.id)
      @images = @show.slides.sort_by {|e| e.position}
    else
      redirect_to '/'
    end
  end

  def edit
    @slideshow = Slideshow.find(params[:id])
    if @slideshow.user_id == current_user.id
      @images = @slideshow.slides.order(:position)
      @user_ps = @slideshow.slide_show_permissions.map { |e| e.user }.uniq
    else
      redirect_to '/'
    end
  end

  def draw_set
    render :partial => '/slideshows/draw', :locals => params
  end

  def update_slide_show_slide_tags
    @slideshow = Slideshow.find(params[:id])

    @slideshow.slides.each do |slide|
      if !params[:tags_string].nil?
        tags = params[:tags_string]
        tag_array = tags.split(',')
        tag_array.each do |tg|
          if Tag.exists?(:name => tg)
            t = Tag.find_by_name(tg)
            if !Tagging.exists?(:tag_id => t.id, :slide_id => slide.id)
              Tagging.create(:tag_id => t.id, :slide_id => slide.id)
            end
          else
            t = Tag.create(:name => tg)
            Tagging.create(:tag_id => t.id, :slide_id => slide.id)
          end
        end
      end
    end

      redirect_to :back
  end

  def draw_set_random
    num_poses = params[:num]
    length = params[:pose_l]
    render :partial => '/slideshows/draw_random', :locals => {:pose_length => length, :pose_number => num_poses}
  end

# draw sets
  def draw_set_your
    render :partial => '/slideshows/draw_yours', :locals => params
  end

  def draw_set_likes
    render :partial => '/slideshows/draw_likes', :locals => params
  end

  def get_images_from_show_your
    images_spent = params[:already].split(',').map { |e| e.to_i }
    if images_spent.empty?
      images_spent = [1,2]
    end
    @slide = Slide.where('id not in (?) and user_id = ?', images_spent, current_user.id).sample
    render :json => @slide
  end

  def get_images_from_show_likes
    images_spent = params[:already].split(',').map { |e| e.to_i }
    if images_spent.empty?
      images_spent = [1,2]
    end
    @slides_liked_array = current_user.likes.map { |e| e.slide_id }.uniq
    @slides_liked = Slide.where("id in (?) and id not in (?) and public = ?", @slides_liked_array, images_spent, true)
    @slide = @slides_liked.sample
    render :json => @slide
  end

# draw sets

  def update_image_position
    @slideshow = Slideshow.find(params[:id])
    @slideshow.slides.find_by_id(params[:slide_id]).update_attributes(:position => params[:position])
    render :nothing => true
  end


  def toggle_public
    @slideshow = Slideshow.find(params[:id])
    now = @slideshow.public
    @slideshow.update_attributes(:public => !now)
    @slideshow.slides.each do |slide|
      slide.update_attributes(:public => !now)
    end

    render :json => @slideshow
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
    render :json => @show
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

  def get_images_from_show_tag
    tag = Tag.find(params[:tag])
    images_spent = params[:already].split(',').map { |e| e.to_i }
    if images_spent.empty?
      images_spent = [1,2]
    end
    tagging_slides = Tagging.where('tag_id = ?', tag.id).map { |e| e.slide_id }
    @slide = Slide.where('id not in (?) and id in (?) and public = ?', images_spent, tagging_slides, true).sample
    render :json => @slide
  end

  def get_images_from_show_random
    images_spent = params[:already].split(',').map { |e| e.to_i }
    if images_spent.empty?
      images_spent = [1,2]
    end
    @slide = Slide.where('id not in (?) and public = ? = ?', images_spen, truet, true).sample
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

  def get_image_slide_show
    @show = Slideshow.find(params[:id])
    image = @show.slides.sample
    render :json => image
  end

  def mark_all_slides_nsfw
    @show = Slideshow.find(params[:id])
    @show.slides.each do |image|
      image.update_attributes(:nsfw => true)
    end

    render :nothing => true
  end

  def get_image_slide_show_tags
    tag = Tag.find(params[:id])
    taggings = Tagging.where('tag_id = ?', tag.id)
    image = taggings.sample.slide

    render :json => image
  end

  private

  def slideshow_params
    params.require(:info).permit(:title)
  end

end
