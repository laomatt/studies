class SlidesController < ApplicationController
  before_action :authenticate_user!, :except => [:find_slide, :get_partial]
  before_filter :find_slide, :except => [:browse_tags]
  skip_before_action :verify_authenticity_token, :only => [:like_a_slide, :destroy_this_slide, :unlike_slide, :toggle_nsfw]

  def like_a_slide
    Like.create(:slide_id => @slide.id, :user_id => current_user.id)

    render :nothing => true
  end

  def update
    @slide.update_attributes(slide_params)

    # tag the slide
    if !params[:tags_string].nil?
      tags = params[:tags_string]
      tag_array = tags.split(',')
      tag_array.each do |tg|
        if Tag.exists?(:name => tg)
          t = Tag.find_by_name(tg)
          if !Tagging.exists?(:tag_id => t.id, :slide_id => @slide.id)
            Tagging.create(:tag_id => t.id, :slide_id => @slide.id)
          end
        else
          t = Tag.create(:name => tg)
          Tagging.create(:tag_id => t.id, :slide_id => @slide.id)
        end
      end
    end

    render :json => @slide
  end

  def destroy_this_slide
    @slide.likes.each do |like|
      like.delete
    end

    slide = @slide.destroy
    render :json => slide
  end

  def add_to_list
    list = List.find(params[:list_id])
    ListSlide.create(:slide_id => @slide.id, :list_id => list.id)

    render :nothing => true
  end

  def unlike_slide
    like = Like.where('slide_id = ? and user_id = ?',@slide.id,current_user.id).first
    Like.delete(like.id)

    render :nothing => true
  end

  def get_partial
    info = Hash[@slide.attributes.map{ |k, v| [k.to_sym, v] }]
    if params[:type] == 'inspect'
      info[:tag_list] = @slide.taggings.map { |e| e.tag.name }.join(',')
      render :partial => '/slideshows/slidedisplay', :locals => info
    elsif params[:type] == 'show'
      info[:tag_list] = @slide.taggings.map { |e| e.tag.name }.join(',')
      render :partial => '/slides/show', :locals => info
    elsif params[:type] == 'edit'
      info[:tag_list] = @slide.taggings.map { |e| e.tag.name }.join(',')
      render :partial => '/slideshows/slideedit', :locals => info
    elsif params[:type] == 'delete'
      render :partial => '/slideshows/deleteslide', :locals => info
    end
  end

  def toggle_nsfw
    now = @slide.nsfw
    @slide.update_attributes(:nsfw => !now)

    render :json => @slide
  end

  private

  def find_slide
    @slide = Slide.find(params[:id])
  end

  def slide_params
    params.require(:slide_info).permit(:title,:ext_url,:nsfw)
  end
end
