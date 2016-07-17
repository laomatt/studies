class HomeController < ApplicationController
  before_action :authenticate_user!, :except =>  [:index, :get_faq]
  layout 'application'
  def index
    @slideshows = Slideshow.where(:public => true).order(:updated_at => :desc).paginate(:page => params[:page], :per_page => 100)
  end

  def user_private_slideshows
    shows = current_user.slide_show_permissions.map { |e| e.slideshow }
    @slideshows = shows.sort_by{|e| e.updated_at}

  end

  def ind
    if !current_user.admin
      redirect_to '/'
    end
  end

  def user
  end

  def get_faq
    render :partial => 'home/faq_modal'
  end

  def user_slideshows
    @user = current_user
    @slideshows_public = @user.slideshows.select {|e| e.public }
    @slideshows_private = @user.slideshows.select {|e| !e.public }
    @slides = @user.slides
  end

  def exp
    if !current_user.admin
      redirect_to '/'
    end

    tags = params[:cat]
    u = UrlBank.create(:url => params[:url], :tags => tags)
    render :json => u
  end

  def user_slides
    @user = current_user
    @slides = @user.slides
    @slides_liked_array = @user.likes.map { |e| e.slide_id }.uniq

    @slides_liked = Slide.where("id in (?)", @slides_liked_array)
  end


  def create_slide_show
    @user = current_user
  end

  def save_slide_show
    @slideshow = Slideshow.create(slideshow_params)
    @slideshow.update_attributes(:user_id => current_user.id, :public => false)

    redirect_to "/slideshows/#{@slideshow.id}/edit"
  end

  def upload_images
    @slideshow = Slideshow.find(params[:id]);
  end

  def add_image
    uploaded_io = params[:image_this]

    io_array = []
    uploaded_io.each do |image|
      if image[1].present?
        io_array << image[1]
      end
    end

    @slideshow = Slideshow.find(params[:id])

    # @job_id - MsgQ.new_progress_tacker()

    ImageProcessor.perform_async(@slideshow.id, current_user.id, io_array, params[:tags_string])

    render :nothing => true
  end


  def check_progress

  end

  def add_image_url
    slide = Slide.create(slide_params)
    render :json => slide
  end

  def add_image_community
    slide = Slide.create(slide_params)
    render :json => slide
  end

  private

  def slideshow_params
    params.require(:info).permit(:title)
  end

  def slide_params
    params.require(:info).permit(:title, :ext_url, :slideshow_id, :nsfw)
  end

end
