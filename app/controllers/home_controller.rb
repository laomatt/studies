class HomeController < ApplicationController
  before_action :authenticate_user!, :except => :index
  layout 'application'
  def index
    @slideshows = Slideshow.where(:public => true).paginate(:page => params[:page], :per_page => 16)
  end

  def ind
    if !current_user.admin
      redirect_to '/'
    end
  end

  def user
  end

  def user_slideshows
    @user = current_user
    @slideshows = @user.slideshows
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
    @slideshow = Slideshow.create(slideshow_params);
    @slideshow.update_attributes(:user_id => current_user.id)

    redirect_to "/slideshows/#{@slideshow.id}/edit"
  end

  def upload_images
    @slideshow = Slideshow.find(params[:id]);
  end

  def add_image
    require 'fileutils'
    @slideshow = Slideshow.find(params[:id])
    uploaded_io = params[:slideshow][:picture]
p "----a----#{uploaded_io.original_filename}-------"
    ::File.open(Rails.root.join('tmp', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
p "----------ff----- #{uploaded_io.read == nil}"
    obj_key = "#{current_user.email}/#{uploaded_io.original_filename}"
p "----------ff----- #{obj_key}"
    obj = S3_BUCKET.object(obj_key)
p "----------ff----- #{obj}"
    obj.upload_file("public/uploads/#{uploaded_io.original_filename}", {acl: 'public-read'})
p "-------url--------#{obj.public_url.to_s} "
    slide = Slide.create(:ext_url => obj.public_url.to_s, :slideshow_id => @slideshow.id, :title => uploaded_io.original_filename, :on_s3 => true)

p "--------------- slide  --- #{slide.ext_url}"
    File.delete(Rails.root + "tmp/#{uploaded_io.original_filename}")
    render :json => slide
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
    params.require(:info).permit(:title, :ext_url, :slideshow_id, :tags)
  end

end
