# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActionController::RoutingError, with: :route_not_found
  unless Rails.env.test?
    # rescue_from Blacklight::Exceptions::InvalidSolrID, with: :render_404
    rescue_from ActionView::MissingTemplate, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::MissingFile, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from CanCan::AccessDenied, with: :render_401
    rescue_from ActionView::Template::Error, with: :render_500
    rescue_from ActiveRecord::StatementInvalid, with: :render_500
    rescue_from Mysql2::Error, with: :render_500
    rescue_from Net::LDAP::LdapError, with: :render_500
    # rescue_from Redis::CannotConnectError, with: :render_500
    rescue_from Errno::ECONNREFUSED, with: :render_500
    rescue_from ActionDispatch::Cookies::CookieOverflow, with: :render_500
    rescue_from RuntimeError, with: :render_500
    rescue_from RestClient::Unauthorized, RestClient::Forbidden, with: :render_401
    rescue_from Author::NotAuthorizedToEdit, with: :render_401
    rescue_from RestClient::ExceptionWithResponse, with: :render_500
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def index
    render 'home/index', layout: 'home'
  end

  def login
    Rails.logger.info 'LOGGING IN APP CONTROLLER'
    # webaccess_login_url = WebAccess.new(request.env['HTTP_REFERER']).login_url
    Rails.logger.info "REDIRECTING---" + "#{WebAccess.new(request.env['HTTP_REFERER']).login_url}  #{Time.zone.now}"
    # redirect_to webaccess_login_url # unless Rails.env.development? || Rails.env.test?
    redirect_to webaccess_login_url
  end

  def logout
    session[:access_id] = nil
    session[:user_role] = nil
    session[:user_name] = nil
    # make any local additions here (e.g. expiring local sessions, etc.)
    # adapted from here: http://cosign.git.sourceforge.net/git/gitweb.cgi?p=cosign/cosign;a=blob;f=scripts/logout/logout.php;h=3779248c754001bfa4ea8e1224028be2b978f3ec;hb=HEAD
    cookies.delete(request.env['COSIGN_SERVICE']) if request.env['COSIGN_SERVICE']
    redirect_to webaccess_logout_url unless Rails.env.test?
    # redirect_to WebAccess.new.logout_url unless Rails.env.development? || Rails.env.test?
  end

  def autocomplete
    results = LdapUniversityDirectory.new.autocomplete(params[:term])
    render json: results
  end

  def current_remote_user
    Devise::Strategies::WebaccessAuthenticatable.new(nil).remote_user(request.headers)
  end

  def render_404(exception)
    logger.error("Rendering 404 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/404', layout: "error", formats: %i[html json], status: 404
  end

  def render_500(exception)
    logger.error("Rendering 500 page due to exception: #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/500', layout: "error", formats: %i[html json], status: 500
  end

  def render_401(exception)
    logger.error("Rendering 401 page due to exception #{exception.inspect} - #{exception.backtrace if exception.respond_to? :backtrace}")
    render template: '/error/401', layout: "error", formats: %i[html json], status: 401
  end

  protected

  def webaccess_login_url
    WebAccess.new(request.env['HTTP_REFERER']).login_url
  end

  def webaccess_logout_url
    WebAccess.new.logout_url
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:access_id)
  end
end
