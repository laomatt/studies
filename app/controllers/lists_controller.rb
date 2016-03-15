class ListsController < ApplicationController
  before_action :authenticate_user!

  def index
    @lists = current_user.lists
  end

  def show
    @list = List.find(params[:id])
  end

  def make
    list = List.create(list_params)
    list.update_attributes(:user_id => current_user.id)
    redirect_to "/lists/#{list.id}/show"
  end

  private

  def list_params
    params.require(:info).permit(:title)
  end


end
