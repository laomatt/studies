class HomeController < ApplicationController
  before_action :authenticate_user!, :except =>  [:index, :get_faq]
  layout 'application'
  def index
    @slideshows = Slideshow.where(:public => true).order(:updated_at => :desc).paginate(:page => params[:page], :per_page => 20)
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
    require 'fileutils'
    require "tinify"
    uploaded_io = params[:slideshow][:picture]

    if uploaded_io.size > 2000000
      render :json => {:error=> 'big', :message => 'Sorry, but the file size cannot exceed 2mb'}
    else

      Tinify.key = ENV['TINY_PNG_API_KEY']

      @slideshow = Slideshow.find(params[:id])
      tags = params[:tags_string]
      ::File.open(Rails.root.join('tmp', uploaded_io.original_filename), 'wb') do |file|
        file.write(uploaded_io.read)
      end



      if uploaded_io.size > 700000
        # source_full = Tinify.from_file("tmp/#{uploaded_io.original_filename}")
        resized_full = source_full.resize(:method => 'scale', :height => 1000)
        resized_full.to_file("tmp/#{uploaded_io.original_filename}")
      end

      # source_thumb = Tinify.from_file("tmp/#{uploaded_io.original_filename}")
      source_thumb.resize(:method => 'scale', :height => 400)
      source_thumb.to_file("tmp/thumbnail-#{uploaded_io.original_filename}")

      obj_key = "#{current_user.email}/#{@slideshow.id}/#{uploaded_io.original_filename}"
      obj = S3_BUCKET.object(obj_key)
      obj.upload_file("tmp/#{uploaded_io.original_filename}", {acl: 'public-read'})

      obj_key_thumb = "#{current_user.email}/#{@slideshow.id}/thumbnails/#{uploaded_io.original_filename}"
      obj_thumb = S3_BUCKET.object(obj_key_thumb)
      obj_thumb.upload_file("tmp/thumbnail-#{uploaded_io.original_filename}", {acl: 'public-read'})


      slide = Slide.create(:ext_url => obj.public_url.to_s, :slideshow_id => @slideshow.id, :title => uploaded_io.original_filename, :on_s3 => true, :thumb_url => obj_thumb.public_url.to_s, :user_id => current_user.id)

      # tag the slide
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

      File.delete(Rails.root + "tmp/#{uploaded_io.original_filename}")
      File.delete(Rails.root + "tmp/thumbnail-#{uploaded_io.original_filename}")
      render :json => {:error=> 'none', :slide => slide}
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
