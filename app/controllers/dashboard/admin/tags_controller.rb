class Dashboard::Admin::TagsController < Dashboard::Admin::AdminController
  def index
    @tags = @paginate = Tag.all.order('id DESC').paginate(:page => params[:page])
  end

  def new
    @tag = Tag.new
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(tag_params)
    @tag.save
    redirect_to dashboard_admin_tags_path
  end

  def update
    @tag = Tag.find(params[:id])

    if @tag.update(tag_params)
      redirect_to dashboard_admin_tags_path
    else
      render 'edit'
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to dashboard_admin_tags_path
  end

  private
  def tag_params
    params.require(:tag).permit(:name)
  end
end
