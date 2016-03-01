class HomeController < ApplicationController
  before_action :authenticate_user!, :except => :index
  layout 'application'
  def index
    @slideshows = Slideshow.where(:public => true).paginate(:page => params[:page], :per_page => 18)
  end

  def user

  end

  def create_slide_show
    @user = current_user
  end

  def save_slide_show
    @slideshow = Slideshow.create(slideshow_params);
    @slideshow.update_attributes(:user_id => current_user.id)

    redirect_to "/home/#{@slideshow.id}/upload_images"
  end

  def upload_images
    @slideshow = Slideshow.find(params[:id]);
  end

  def add_image
    @slideshow = Slideshow.find(params[:id])
    uploaded_io = params[:slideshow][:picture]

    File.open(Rails.root.join('public', "uploads", uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end

    obj_key = "#{current_user.email}/#{uploaded_io.original_filename}"
    obj = S3_BUCKET.object(obj_key)
    obj.upload_file("public/uploads/#{uploaded_io.original_filename}", {acl: 'public-read'})


    slide = Slide.create(:ext_url => obj.public_url.to_s, :slideshow_id => @slideshow.id, :title => uploaded_io.original_filename)

    File.delete(Rails.root + "public/uploads/#{uploaded_io.original_filename}")
    render :json => slide
  end

  private

  def slideshow_params
    params.require(:info).permit(:title)
  end

end
