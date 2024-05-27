class PostsController < ApplicationController
  before_action :require_login, only: [:new, :select]

  def index
    # サイドバーを非表示にする
    @hide_sidebar = true
    # Ransackを利用して検索機能を実装
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:user).order("created_at desc")
  end

  def search
    @posts = Post.where("title like ? or content like ?", "%#{params[:q]}%", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
  end

  def new
  end

  def select
    user_input = params[:title]
    @tankas = request_tanka_from_openai(user_input)

    # セッションに保存
    session[:title] = user_input
    session[:tankas] = @tankas

    render 'select'
  end

  def create
    @post = Post.new(post_params)
    # セッションからuser_inputを取得
    @post.title = session[:title]
    # 現在のユーザーを@postの作成者として設定する
    @post.user = current_user

    # プロンプトを作成
    prompt = @post.title
    # 画像生成APIを利用して画像を生成
    image_api = OpenAi::ImageApi.new
    s3_image_url = image_api.generate_and_upload_image_to_s3(prompt)
    # 生成した画像のURLを@postに保存
    @post.image_url = s3_image_url

    if @post.save
      # セッションからuser_inputを削除
      session.delete(:title)
      redirect_to @post, notice: '短歌を投稿しました。'
    else
      render 'new'
    end
  end

  def show
    @post = Post.find(params[:id])
    
    # OGP設定
    set_meta_tags og: {
      title: "短歌つくったー。",
      description: "ユーザーが入力した文章をもとに、AIが短歌を生成するサービスです。",
      url: request.original_url,
      # 短歌の画像を動的に表示したかったがうまくいかなかったため、固定の画像を表示
      # image: url_for(@post.image_url)
      image: view_context.image_url('main_logo.png')
    },
    twitter: {
      card: "summary_large_image",
      site: "@",
      title: "短歌つくったー。",
      description: "ユーザーが入力した文章をもとに、AIが短歌を生成するサービスです。",
      image: url_for(@post.image_url)
      # image: view_context.image_url('main_logo.png')
    }

    # TwitterのシェアURLを生成
    if @post.user_id.present?
      @twitter_share_url = "https://twitter.com/intent/tweet?text=#{ERB::Util.url_encode("ここで一首。\n◤￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣\n #{@post.content}\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿◢\n#{@post.user.name}  心の一首。")}&url=#{request.original_url}"
    else
      # 初期データに名前がないため、名前がない場合は「詠み人知らず」と表示
      @twitter_share_url = "https://twitter.com/intent/tweet?text=#{ERB::Util.url_encode("ここで一首。\n◤￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣\n #{@post.content}\n＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿◢\n詠み人知らず  心の一首。")}&url=#{request.original_url}"
    end
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    redirect_to posts_path, notice: '短歌を削除しました。', status: :see_other
  end

  private

  def request_tanka_from_openai(user_input)
    predefind_response = "
    # Prompt
    「#{user_input}」という言葉をもとにして短歌を生成してください。
    生成する短歌の数：5首を厳守
    生成する短歌の形式：5・7・5・7・7の31音を厳守
    生成する短歌の言葉のスタイル：古語
    1首読んだら、改行してから次の短歌を生成してください。
    短歌の冒頭に数字は不要です。

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

    chat_api = OpenAi::ChatApi.new(prompt)
    tanka_response = chat_api.chat(user_input)
    
    tankas = tanka_response.split("\n").reject(&:empty?)
    tankas
  end

  def post_params
    params.require(:post).permit(:content, :title)
  end
end
