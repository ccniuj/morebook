class ShelvesController < ApplicationController
  def index
    @tag_name = params[:tag] if params[:tag]
    @shelves = @paginate = Shelf.all.order('id DESC').paginate(:page => params[:page])
  end

  def show
    @shelf = Shelf.find(params[:id])
  end
end