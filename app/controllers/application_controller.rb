class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def setup
    {
      aws_access_key_id:  ENV["AWSAccessKeyId"],
      aws_secret_access_key:  ENV["AWSSecretKey"],
      associate_tag:  ENV["amazon_assoc_tag"]
    }
  end
end
