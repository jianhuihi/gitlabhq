class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  include Gitlab::CurrentSettings
  include PageLayoutHelper

  before_action :verify_user_oauth_applications_enabled
  before_action :authenticate_user!

  layout 'profile'

  def index
    head :forbidden and return
  end

  def new
    redirect_to applications_profile_url
  end

  def create
    @application = Doorkeeper::Application.new(application_params)

    @application.owner = current_user

    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      redirect_to applications_profile_path, flash: {application: @application}
    end
  end

  def destroy
    if @application.destroy
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :destroy])
    end

    redirect_to applications_profile_url
  end

  private

  def verify_user_oauth_applications_enabled
    return if current_application_settings.user_oauth_applications?

    redirect_to applications_profile_url
  end

  def set_application
    @application = current_user.oauth_applications.find(params[:id])
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render "errors/not_found", layout: "errors", status: 404
  end
end
