class ShelvesController < ApplicationController
  def index
    @shelves =@paginate = Shelf.all.paginate(:page => params[:page])
  end

  def show
    @shelf = Shelf.find(params[:id])
  end
end