class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:grant_permission, :revoke_permission]
  before_action :authenticate_user!

  def search
    if params[:search_type] == 'name'
      results = User.where('name like ?', "%#{params[:search_body]}%").limit(10)
    else
      results = User.where('email like ?', "%#{params[:search_body]}%").limit(10)
    end

    res = results.reject {|e| SlideShowPermission.exists?(:slideshow_id => params[:slideshow_id], :user_id => e.id)}
    render :json => {:users => res}
  end

  def grant_permission
    slideshow = Slideshow.find(params[:slideshow_id])
    if current_user.id == slideshow.user_id
      SlideShowPermission.create(:user_id => params[:user_id], :slideshow_id => slideshow.id)
    end
    render :nothing => true
  end

  def revoke_permission
    slideshow = Slideshow.find(params[:slideshow_id])
    slideshow_permission = SlideShowPermission.where('user_id = ? and slideshow_id = ?', params[:user_id], slideshow.id)
    if current_user.id == slideshow.user_id
      slideshow_permission.destroy_all
    end
    render :nothing => true
  end
end
