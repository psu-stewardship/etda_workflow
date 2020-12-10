# frozen_string_literal: true

class AdminController < ApplicationController
  protect_from_forgery with: :exception
  before_action :store_user_location!, if: :storable_location?

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  # before_action :clear_admin
  before_action :authenticate_or_redirect
  before_action :find_or_initialize_admin

  layout 'admin'

  protected

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:admin, request.fullpath)
  end

  def find_or_initialize_admin
    @admin ||= Admin.find_or_initialize_by(access_id: current_admin.access_id)
    # Rails.logger.info "current_admin = #{current_admin.inspect}"
    session[:user_name] = @admin.full_name
  end

  def clear_admin
    # Rails.logger.info 'CLEARING ADMIN...........'
    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    #  logout clears the entire session including flash messages
    request.env['warden'].logout if current_remote_user.nil? || !valid_admin_session?
  end

  def authenticate_or_redirect
    session[:user_role] = 'admin'
    authenticate_admin! unless current_admin
    session[:access_id] = current_admin[:access_id]

    if valid_admin?
      authorize! :administer, :all
    else
      redirect_to '/401' # unauthorized page
    end
  end

  def valid_admin?
    this_admin = current_remote_user
    user_is_admin = if current_admin.nil?
      LdapUniversityDirectory.new.in_admin_group?(this_admin)
                    else
      current_admin.administrator?
                    end
    session[:user_role] = 'admin' if user_is_admin
    user_is_admin
  end

  def valid_admin_session?
    return false if session[:user_role] != 'admin'

    current_user_check
  end

  def current_user_check
    current_remote_user == current_admin.access_id
  end

  def current_ability
    @current_ability ||= AdminAbility.new(current_admin)
  end
end
