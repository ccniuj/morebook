class Dashboard::Admin::ShelvesController < Dashboard::Admin::AdminController
  def index
    @shelves = @paginate = Shelf.all.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @shelf = Shelf.new
  end

  def edit
    @shelf = Shelf.find(params[:id])
  end

  def update
    @shelf = Shelf.find(params[:id])
    if @shelf.update(shelf_params)
      redirect_to dashboard_admin_shelves_path
    else
      render 'edit'
    end
  end

  def destroy
    @shelf = Shelf.find(params[:id])
    @shelf.destroy
    redirect_to dashboard_admin_shelves_path
  end

  private
  def shelf_params
    params.require(:shelf).permit(:name, :descrition)
  end
end
