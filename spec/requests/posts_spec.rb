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
      user_input = "ケーキが食べたいなあ"
      predefind_response = "
    # Prompt
    背景情報：ユーザーが「#{user_input}」というをもとにして短歌を生成したいとリクエストしました。
    短歌：「#{user_input}」という言葉をもとにして短歌を生成してください。
    生成する短歌の内容：「#{user_input}」という言葉をもとにして短歌を生成してください。
    生成する短歌の数：5パターン
    生成する短歌の形式：5-7-5-7-7
    生成する短歌の言葉の種類：「#{user_input}」という言葉をもとにして短歌を生成してください。
    生成する短歌の言葉の難易度：中
    生成する短歌の言葉の内容：「#{user_input}」という言葉をもとにして短歌を生成してください。
    生成する短歌の言葉の感情：中立
    生成する短歌の言葉のジャンル：一般
    生成する短歌の言葉のトーン：中立
    生成する短歌の言葉のスタイル：古語
    生成する短歌の言葉のテーマ：一般
    生成する短歌の言葉のトピック：一般
    生成する短歌の言葉のキーワード：一般
    生成する短歌の言葉のコンテキスト：一般
    生成する短歌の言葉のコンセプト：一般
    生成する短歌の言葉のアイデア：一般
    生成する短歌の言葉の概念：一般
    生成する短歌の言葉の構造：一般
    生成する短歌の言葉の形：一般
    生成する短歌の言葉のパターン：一般
    生成する短歌の言葉のスキーム：一般
    生成する短歌の言葉のフレーズ：日本の短歌に用いられるような、古風な言葉を使って短歌を生成してください。
    生成する短歌の言葉のフレーム：句の音の数を以下のように指定します。生成した短歌をひらがなに書き換えた時の音の数が、5-7-5-7-7になるように短歌を生成してください。

    # Example
    ## input
    user_input: ケーキが食べたいなあ
    ## output
    甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を
    求めしは 甘き果実の 心地に 空腹を癒し 舌鼓う時を
    焼きたての 甘き蜜漬けの ケーキの 香りに誘われ 口舌乾かす
    忘れがたき 甘きケーキの 味に酔い 舌鼓う日まで 待ちわびつつ
    糖蜜に満つ 幸せの一刻 求めては 飢えたる魂が 舌を休めん
    "

      prompt = "#{user_input} + #{predefind_response}"

      stub_request(:post, "https://api.openai.com/v1/chat/completions")
        .with(
          body: {
            model: "gpt-3.5-turbo",
            max_tokens: 512,
            temperature: 0.9,
            messages: [
              { role: "system", content: prompt },
              { role: "user", content: user_input }
            ]
          }.to_json,
          headers: {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{ENV["OPEN_AI_API_KEY"]}"
          }
        )
        .to_return(
          status: 200,
          body: '{"choices":[{"message": {"content":"甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を\n"}}]}',
          headers: { "Content-Type" => "application/json" }
        )

      post select_posts_path, params: { title: user_input }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を")
    end
  end

  describe "POST /posts/create" do
    it "短歌に合わせた画像が生成されること" do
      user_select = "甘美なる 願いはケーキに 満たされぬ 舌を待ちわび 甘美の味を"

      # セッションに保存する内容を設定
      allow_any_instance_of(PostsController).to receive(:session).and_return({ title: "ケーキが食べたいなあ", tankas: [user_select] })

      # スタブリクエストの設定
      stub_request(:post, "https://api.openai.com/v1/images/generations")
        .with(
          body: {
            prompt: "ケーキが食べたいなあ",
            model: "dall-e-3",
            n: 1,
            size: "1024x1024"
          }.to_json,
          headers: {
            'Authorization' => "Bearer #{ENV["OPEN_AI_API_KEY"]}",
            'Content-Type' => 'application/json'
          }
        )
        .to_return(
          status: 200,
          body: {
            data: [
              {
                url: "https://example.com/image.png"
              }
            ]
          }.to_json,
          headers: {}
        )

      # S3アップロードのスタブ化
      allow_any_instance_of(OpenAi::ImageApi).to receive(:upload_image_to_s3).and_return("https://s3.example.com/uploads/generated_image.png")

      # Post作成時に手動でUserのIDをセット
      allow_any_instance_of(Post).to receive(:user).and_return(@user)

      post posts_path, params: { post: { title: "ケーキが食べたいなあ", content: user_select } }

      # 作成されたPostオブジェクトを取得
      created_post = Post.last

      # Postオブジェクトが作成されているかチェック
      expect(created_post).not_to be_nil

      expect(response).to have_http_status(:redirect)
      follow_redirect!

      expect(response.body).to include("短歌を投稿しました。")
      expect(Post.last.image_url).to eq("https://s3.example.com/uploads/generated_image.png")
    end
  end
end
