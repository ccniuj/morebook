class Dashboard::ShelvesController < Dashboard::DashboardController
  def index
    @shelves = @paginate = Shelf.all.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @shelf = Shelf.new
  end

  def edit
    @shelf = Shelf.find(params[:id])
  end

  def create
    @shelf = Shelf.new(shelf_params)
    @shelf.save
    @user_shelf = UserShelf.new(:user_id => current_user.id, 
                                :shelf_id => @shelf.id, 
                                :is_owner? => true)
    if @user_shelf.save
      redirect_to dashboard_shelves_path
    else
      @shelf.destroy
    end
  end

  def update
    @shelf = Shelf.find(params[:id])
    if @shelf.update(shelf_params)
      redirect_to dashboard_shelves_path
    else
      render 'edit'
    end
  end

  def destroy
    @shelf = Shelf.find(params[:id])
    @shelf.destroy
    redirect_to dashboard_shelves_path
  end

  private

  def shelf_params
    params.require(:shelf).permit(:name, :description, :cover)
  end
end
