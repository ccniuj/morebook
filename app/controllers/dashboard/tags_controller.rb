class Dashboard::TagsController < Dashboard::DashboardController
  def add_tag
    respond_to do |format|
      format.html
      format.json {render json: {:test => 1}}
    end
  end
end