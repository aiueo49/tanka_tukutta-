require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  before do
    @user = User.create(name: "test", email: "test1@example.com", password: "password", password_confirmation: "password")
  end

  describe "POST /login" do
    it "ログインに成功すること" do
      post login_path, params: { email: @user.email, password: @user.password }
      # ログインに成功した場合のみリダイレクトするので、リダイレクトされることを確認すればログインに成功したことがわかる
      expect(response).to have_http_status(:redirect)
    end
  end
end
