class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lists = current_user.lists
  end

  def show
    @list = List.find(params[:id])
    @images = @list.list_slides.map { |e| e.slide }
  end

  def make
    list = List.create(list_params)
    list.update_attributes(:user_id => current_user.id)
    redirect_to "/lists/#{list.id}/show"
  end

  def draw_set
    render :partial => '/lists/draw', :locals => params
  end

  def get_images_from_list
    @list = List.find(params[:id])
    images_spent = params[:already].split(',')
    idx = params[:slin]
    @slides = @list.list_slides.map { |e| e.slide }
    if params[:random]
      @slide = @slides.select{ |e| !images_spent.include?(e.id.to_s)}.sample
    else
      @slide = @slides.order(:position)[idx]
    end

    render :json => @slide
  end

  private

  def list_params
    params.require(:info).permit(:title)
  end


end
