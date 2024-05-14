class PostsController < ApplicationController
  before_action :require_login, only: [:new, :generate_tanka]

  def index
    # @posts = Post.all
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:user).order("created_at desc")
  end

  def search
    @posts = Post.where("title like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
  end

  def current_user_page
    @current_user_posts = current_user.posts
  end

  def new
  end

  def generate_tanka
    user_input = params[:title]
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

    chat_api = OpenAi::ChatApi.new(prompt)
    tanka_response = chat_api.chat(user_input)
    
    @tankas = tanka_response.split("\n").reject(&:empty?)

    # セッションに保存
    session[:title] = user_input
    session[:tankas] = @tankas

    render 'generate_tanka'
  end

  def create
    @post = Post.new(post_params)
    # セッションからuser_inputを取得
    @post.title = session[:title]
    # 現在のユーザーを@postの作成者として設定する
    @post.user = current_user

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
  end

  def destroy
    post = current_user.posts.find(params[:id])
    post.destroy!
    redirect_to posts_path, notice: '短歌を削除しました。', status: :see_other
  end

  private

  def post_params
    params.require(:post).permit(:content, :title)
  end
end
