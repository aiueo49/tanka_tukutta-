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

  describe "POST /posts/select" do
    it "短歌が生成されること" do
      # 外部APIの呼び出しをスタブ化
      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .with(
          body: {
            model: "gpt-3.5-turbo",
            max_tokens: 512,
            temperature: 0.9,
            messages: [
              { role: "system", content: "ケーキが食べたいなあ" },
              { role: "user", content: "ケーキが食べたいなあ"}
            ]
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{ENV["OPEN_AI_API_KEY"]}"
          }
        )
        .to_return(
          status: 200,
          body: '{"choices":[{"text":"甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を\n"}]}',
          headers: { "Content-Type" => "application/json" }
        )
      post select_posts_path, params: { title: "ケーキが食べたいなあ" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を")
    end
  end
end

