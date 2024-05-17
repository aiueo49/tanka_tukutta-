class MypagesController < ApplicationController
  def index
  # def current_user_page
    @current_user_posts = current_user.posts
  end
end
