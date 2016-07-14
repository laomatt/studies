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
    begin
    uploaded_io = params[:image_this]

    if uploaded_io.size > 2000000
      render :json => {:error=> 'big', :message => 'Sorry, but the file size cannot exceed 2mb'}
      return
    else

      @slideshow = Slideshow.find(params[:id])
      tags = params[:tags_string]


      slide = Slide.new(:slideshow_id => @slideshow.id, :title => uploaded_io.original_filename, :on_s3 => true, :user_id => current_user.id)
      slide.file = uploaded_io
      slide.save!

      slide.ext_url = slide.file.url
      slide.thumb_url = slide.file.thumb.url

      slide.save!

      if !params[:tags_string].nil?
        tags = params[:tags_string]
        tag_array = tags.split(',')
        tag_array.each do |tg|
          if Tag.exists?(:name => tg)
            t = Tag.find(:name => tg)
            Tagging.create(:tag_id => t.id, :slide_id => slide.id)
          else
            t = Tag.create(:name => tg)
            Tagging.create(:tag_id => t.id, :slide_id => slide.id)
          end
        end
      end


      render :json => {:error=> 'none', :slide => slide}
    end

    rescue => e
      render :json => {:error=> 'exception', :slide => e.to_s}
    end


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
