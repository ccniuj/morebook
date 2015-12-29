class Dashboard::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :create_profile
  layout 'dashboard'
  
  @@selfie_default_url = 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTMQRG8v0aaUxcbIIBX9rAlnIykCgxzHLn3t_zILkWwt-kOYaP80z0t-ZQ'
  
  private

  def create_profile
    current_user.profile ||= Profile.create(
      :user_id => current_user.id,
      :name    => current_user.name,
      :email   => current_user.email,
      :selfie  => @@selfie_default_url
      )
  end
end