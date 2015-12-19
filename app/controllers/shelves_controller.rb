class ShelvesController < ApplicationController
  def index
    @shelves =@paginate = Shelf.all.paginate(:page => params[:page])
  end
end