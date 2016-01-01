class Dashboard::TagsController < Dashboard::DashboardController
  def add_tag
    tag = params['tag']
    respond_to do |format|
      format.html
      format.json { render json: tag }
    end
  end
end