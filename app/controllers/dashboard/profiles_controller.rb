class Dashboard::ProfilesController < Dashboard::DashboardController
  def edit
    @profile = current_user.profile
  end

  def update
    @profile = Profile.find(params[:id])
    if @profile.update(profile_params)
      redirect_to edit_dashboard_profile_path(@profile)
    else
      render 'edit'
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :name_ch, :selfie, :email, :number, :address, :description)
  end
end