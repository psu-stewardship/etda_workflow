# frozen_string_literal: true

require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class WebaccessAuthenticatable < Authenticatable
      def authenticate!
        access_id = remote_user(request.headers)
        @user_role = session[:user_role]
        Rails.logger.info "Devise Access ID ******* #{access_id}"
        if access_id.present? # webaccess successful
          this_object = authentication_type || Author.class
          a = this_object.find_by_access_id(access_id)
          if a.nil?
            if this_object.name == 'Approver'
              obj = this_object.create(access_id: access_id)
            else
              obj = this_object.create(access_id: access_id, psu_email_address: "#{access_id}@psu.edu")
              obj.populate_attributes
            end
          else
            obj = a
            obj.refresh_important_attributes unless obj.class.name == 'Approver'
          end
          success!(obj)
        else
          fail!
        end
      end

      def valid?
        this_remote_user = remote_user(request.headers)
        return true unless this_remote_user.nil?

        false
      end

      def remote_user(headers)
        headers.fetch('REMOTE_USER', nil) || headers.fetch('HTTP_REMOTE_USER', nil)
      end

      protected

      def authentication_type
        if @user_role
          Object.const_get(@user_role.camelcase)
        else
          uri = request.headers['REQUEST_URI']
          this_uri = determine_login_type(uri)
          # this_uri = uri.split('/')[1].camelcase
          Object.const_get(this_uri)
        end
      end

      def determine_login_type(uri)
        this_uri = uri.split('/')
        return 'Author' unless this_uri.length > 1

        this_uri = uri.split('/')[1].camelcase
        this_uri = 'Author' unless ['Author', 'Admin', 'Approver'].include? this_uri
        this_uri
      end
    end
  end
end

Warden::Strategies.add(:webaccess_authenticatable, Devise::Strategies::WebaccessAuthenticatable)
