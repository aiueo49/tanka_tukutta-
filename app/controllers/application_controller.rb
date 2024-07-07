class ApplicationController < ActionController::Base
  helper_method :first_visit

  # 500エラーテスト用
  def raise_500
    raise "Internal 500 Error"
  end

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

