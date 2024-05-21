class ApplicationController < ActionController::Base
  private

  def not_authenticated
    redirect_to login_path, alert: "恐れ入りますが、先にログインをお願いいたします。"
  end
end
