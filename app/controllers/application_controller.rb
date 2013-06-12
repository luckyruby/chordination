class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #redirects to dashboard after sign in
  def after_sign_in_path_for(resource)
   scoresheets_path
  end
  
end
