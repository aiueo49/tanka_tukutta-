class MypagesController < ApplicationController
  before_action :require_login

  def index
    # サイドバーを非表示にする
    @hide_sidebar = true
    @current_user_posts = current_user.posts.order("created_at desc")
  end
end
