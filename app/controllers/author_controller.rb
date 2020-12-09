# frozen_string_literal: true

class AuthorController < ApplicationController
  protect_from_forgery with: :exception
  before_action :store_user_location!, if: :storable_location?

  Devise.add_module(:webaccess_authenticatable, strategy: true, controller: :sessions, model: 'devise/models/webaccess_authenticatable')

  # before_action :clear_author
  before_action :authenticate_or_redirect
  # before_action :find_or_initialize_author
  layout 'author'

  protected

  def find_or_initialize_author
    @author = Author.find_or_initialize_by(access_id: current_author.access_id)
    session[:user_name] = @author.full_name || ''
    author_ability
    # Rails.logger.info "current_author = #{current_author.inspect}"
    # redirect_to author_submissions_path
    # redirect to login_path if @author.nil?
  end

  def clear_author
    # Rails.logger.info 'CLEARING AUTHOR...........'
    # only logout if the REMOTE_USER is not set in the HTTP headers and a user is set within warden
    #  logout clears the entire session including flash messages
    request.env['warden'].logout if current_remote_user.nil? || !valid_author_session?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:author, request.fullpath)
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def authenticate_or_redirect
    session[:user_role] = 'author'
    authenticate_author!(user_role: 'author') unless current_author
    session[:access_id] = current_author[:access_id]

    if valid_author?
      find_or_initialize_author
      update_confidential_hold
    else
      redirect_to '/401'
    end
  end

  def valid_author?
    return false if current_remote_user.blank?

    true
  end

  def valid_author_session?
    return false if session[:user_role] != 'author'

    current_user_check
  end

  def current_user_check
    current_remote_user == current_author.access_id
  end

  def author_ability
    @author_ability ||= AuthorAbility.new(current_author, nil, nil)
  end

  def update_confidential_hold
    update_service = ConfidentialHoldUpdateService.new(@author, 'login_controller')
    update_service.update
  end
end
