# frozen_string_literal: true

class RedirectToWebaccessFailure < Devise::FailureApp
  def redirect_url
    '/login'
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  # Overriding, so that we don't set the flash[:alert] with the unauthenticated message
  def redirect
    store_location!
    if flash[:timedout] && flash[:alert]
      flash.keep(:timedout)
      flash.keep(:alert)
    end
    redirect_to redirect_url
  end
end
