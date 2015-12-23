class ShelvesController < ApplicationController
  def index
    @tag_id = Tag.find(params[:tag]).id if params[:tag]
    @shelves = @paginate = Shelf.all.order('id DESC').paginate(:page => params[:page])
  end

  def show
    @shelf = Shelf.find(params[:id])
    @books = Book.joins(:shelves).where('shelves.id = ?', @shelf.id)
  end
end