require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  before do
    @user = User.create(name: "test", email: "test1@example.com", password: "password", password_confirmation: "password")
  end

  describe "POST /login" do
    it "ログインに成功すること" do
      post login_path, params: { email: @user.email, password: @user.password }
      # 成功した場合のみリダイレクトするので、リダイレクトされることを確認すればログインに成功したことがわかる
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include "ログインに成功しました"
    end
  end

  describe "DELETE /logout" do
    it "ログアウトに成功すること" do
      post login_path, params: { email: @user.email, password: @user.password }
      delete logout_path
      # 成功した場合のみリダイレクトするので、リダイレクトされることを確認すればログアウトに成功したことがわかる
      expect(response).to have_http_status(:redirect)
      follow_redirect!
      expect(response.body).to include "ログアウトしました"
    end
  end
end
