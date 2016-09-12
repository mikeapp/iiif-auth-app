class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :user_from_cookie, :user_from_authorization


  def current_user
    @user
  end

  private

  def user_from_cookie
    @user = decrypt cookies[:iiif_auth]
    puts "Cookie provided #{@user} "
  end

  def user_from_authorization
    header = request.headers['HTTP_AUTHORIZATION']
    puts "Header is #{header}"
    if header and header.start_with?('Bearer ')
      bearer, space, token = header.partition(' ')
      puts "Token is #{token}"
      @user = decrypt(token)
      puts "Authorization bearer token provided #{@user}"
    end
  end

  def decrypt(encrypted)
    encryptor = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.iiif_key_base)
    value = encryptor.decrypt_and_verify(encrypted) if encrypted
    value
  end

end
