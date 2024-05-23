require 'rails_helper'

RSpec.describe 'Post', type: :request do
  before do
    @user = User.create(name: "test", email: "test1@example.com", password: "password", password_confirmation: "password")
    post login_path, params: { email: @user.email, password: @user.password }
    # 成功した場合のみリダイレクトするので、リダイレクトされることを確認すればログインに成功したことがわかる
    expect(response).to have_http_status(:redirect)
    follow_redirect!
    expect(response.body).to include "ログインに成功しました"
  end

  describe "GET /posts/new" do
    it "短歌生成フォームが表示されること" do
      get new_post_path
      expect(response).to have_http_status(200)
      expect(response.body).to include "短歌生成フォーム"
    end
  end
end

