class TagsController < ApplicationController
before_filter :find_tag, :except => :browse_tags
  def browse_tags
    @tags = Tag.all
  end

  def show_tag
    @slides = @tag.taggings.map { |e| e.slide }.uniq
  end


  def get_tag_partial
    render :partial => '/slideshows/draw_tag', :locals => {:pose_length => params[:pose_length], :pose_number => params[:pose_number], :tag_id => params[:id]}
  end


  private

  def find_tag
    @tag = Tag.find(params[:id])
  end

end
