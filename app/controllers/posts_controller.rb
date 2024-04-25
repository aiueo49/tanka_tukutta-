class PostsController < ApplicationController
  before_action :require_login, only: [:new, :generate_tanka]

  def new
  end

  def generate_tanka
    user_input = params[:title]
    predefind_response = "入力内容をもとに、5•7•5•7•7の短歌を5パターン考えてください。ただし古語風に。"

    prompt = "#{user_input} + #{predefind_response}"

    chat_api = OpenAi::ChatApi.new(prompt)
    @tanka = chat_api.chat(user_input)
    
    render 'generate_tanka'
  end
end
