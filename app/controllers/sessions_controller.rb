# frozen_string_literal: true

class SessionsController < ApplicationController
  def destroy
    # make any local additions here (e.g. expiring local sessions, etc.)
    # adapted from here: http://cosign.git.sourceforge.net/git/gitweb.cgi?p=cosign/cosign;a=blob;f=scripts/logout/logout.php;h=3779248c754001bfa4ea8e1224028be2b978f3ec;hb=HEAD
    session = nil
    reqeust.env['warden'].logout
    redirect_to '/'
  end

  def new
    # redirect_url = session['return_to']
    # session['return_to'] = nil if redirect_url # clear so we do not get it next time
    # new_url = WebAccess.new(redirect_url || '').login_url
    redirect_to '/login'
  end

  protected

    def webaccess_login_url
      redirect_url = session['return_to']
      session['return_to'] = nil if redirect_url # clear so we do not get it next time
      WebAccess.new(redirect_url || '').login_url
    end

    def webaccess_logout_url
      WebAccess.new.logout_url
    end
end
