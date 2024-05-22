class MypagesController < ApplicationController
  before_action :require_login

  def index
  # def current_user_page
    @current_user_posts = current_user.posts.order("created_at desc")
  end
end
