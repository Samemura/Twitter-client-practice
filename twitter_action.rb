module TwitterAction
  extend ActiveSupport::Concern

  # Usage:
  # store_auth  request.env['omniauth.auth']
  #   -> token is stored to session.
  # client.user.profile_image_url

  def store_auth(auth)
    session[:access_token]        = auth['credentials']['token']
    session[:access_token_secret] = auth['credentials']['secret']
    session[:username]            = auth['extra']['raw_info']['screen_name']
    session[:profile_image_url]   = get_original_size(auth['extra']['raw_info']['profile_image_url_https'])
    Rails.logger.debug("store_token: #{session[:access_token]}")
    Rails.logger.debug("store_image: #{session[:profile_image_url]}")
  end

  def discard_auth
    session[:access_token] = nil
  end

  def logined?
    Rails.logger.debug("loginged?: #{session[:access_token]}")
    session[:access_token].present?
  end

  def user_name
    session[:username]
  end

  def profile_image_url
    Rails.logger.debug("image: #{session[:profile_image_url]}")
    session[:profile_image_url]
  end

  def update_profile_image(image)
    user = client.update_profile_image(image)
    session[:profile_image_url] = get_original_size(user.profile_image_url.to_str)
    # this profime_image_url probably old image as before update.
  end

  private

  def client
    @client ||= ::Twitter::REST::Client.new do |config|
      secrets = Rails.application.secrets.twitter
      config.consumer_key        = secrets['consumer_key']
      config.consumer_secret     = secrets['consumer_secret']
      config.access_token        = session[:access_token]
      config.access_token_secret = session[:access_token_secret]
    end
  end

  def get_original_size(url)
    url.sub('_normal', '')
  end
end
