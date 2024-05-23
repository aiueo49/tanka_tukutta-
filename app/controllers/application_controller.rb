class ApplicationController < ActionController::Base
  helper_method :first_visit

  private

  def not_authenticated
    redirect_to login_path, alert: "恐れ入りますが、先にログインをお願いいたします。"
  end

  def first_visit
    if session[:first_visit].nil?
      session[:first_visit] = "false"
      true
    else
      false
    end
  end
end
