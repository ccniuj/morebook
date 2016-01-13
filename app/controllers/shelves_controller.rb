class ShelvesController < ApplicationController
  def index
    @tag_name = params[:tag] if params[:tag]
    @shelves = @paginate = Shelf.filter_by_tag(@tag_name).paginate(:page => params[:page])
  end

  def show
    @shelf = Shelf.find(params[:id])
  end

  def update_members
    shelf_show_url = params[:shelf_show_url]
    @shelf = Shelf.find(params[:shelf_id])
    
    session[:user_return_to] = shelf_show_url
    authenticate_user!
    session[:user_return_to] = nil

    if @shelf.users.include?(current_user)
      UserShelf.where(user_id: current_user.id).where(shelf_id: @shelf.id).first.delete
    else
      UserShelf.create(user_id: current_user.id, shelf_id: @shelf.id, is_owner?: false)
    end

    redirect_to shelf_path(@shelf)
  end
end