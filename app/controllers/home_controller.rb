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
    @slideshow = Slideshow.find(params[:id])
    slide_array = []

    uploaded_io.each do |image|
      if image[1].present?
        slide = Slide.new(:slideshow_id => @slideshow.id, :title =>image[1].original_filename, :on_s3 => true, :user_id => current_user.id)
        slide.file = image[1]
        slide.save!
        slide_array << slide.id
      end
    end


    render :json => { :slides => slide_array.join(',') }
  end


  def check_progress
    slides = params[:slides_to_check].split(',')
    proc_slides = slides.map { |e| Slide.find(e).file_processing }
    finished_slides_count = proc_slides.select{|e| e == false}.count
    total_slides = proc_slides.count

    percent = ((finished_slides_count.to_f/total_slides.to_f) * 100).to_i
    slide_hash = []

    if percent >= 100
      proc_slides_info = slides.map { |e| Slide.find(e) }
      proc_slides_info.each do |slide|
        slide_hash << { :title => slide.title, :thumb_url => slide.thumb_url, :id => slide.id }
      end
    end

    render :json => { :result => percent, :slides_to_check => params[:slides_to_check], :slides => slide_hash }
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
