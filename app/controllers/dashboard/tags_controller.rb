class Dashboard::TagsController < Dashboard::DashboardController
  def add_tag
    tag_name = params['tag']['tag_name']
    parent_tag_id = params['tag']['parent_tag']['tag_id']
    tag_id = Tag.add_child_tag(parent_tag_id, tag_name)
    params['tag']['tag_id'] = tag_id

    respond_to do |format|
      format.html
      format.json { render json: params['tag'] }
    end
  end
end