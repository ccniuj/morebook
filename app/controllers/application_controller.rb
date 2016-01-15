class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :create_profile
  @@selfie_default_url = 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTMQRG8v0aaUxcbIIBX9rAlnIykCgxzHLn3t_zILkWwt-kOYaP80z0t-ZQ'
  WillPaginate.per_page = 40

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u| 
      u.permit(:name, :email, :password, :password_confirmation, :remember_me) 
    end
  end

  private

  def create_profile
    if current_user
      current_user.profile ||= Profile.create(
        :user_id => current_user.id,
        :name    => current_user.name,
        :email   => current_user.email,
        :selfie  => @@selfie_default_url
        )
    end
  end

  def sign_in(*args)
    cookies[:sid_backup] = request.session_options[:id]
    super(*args)
  end

  def sign_out(*args)
    cookies[:sid_backup] = request.session_options[:id]
    super(*args)
  end

end
