class UserSessionsController < ApplicationController
  def create
    @user = login(params[:email], params[:password])

    if @user
      redirect_back_or_to root_path, notice: 'ログインに成功しました'
    else
      @user = User.new(email: params[:email])
      flash.now[:alert] = 'ログインに失敗しました'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, status: :see_other, notice: 'ログアウトしました'
  end

  def guest_login
    # 短歌作成者を表示するため使う可能性があるのでインスタンス変数に代入しておく
    @guest_user = User.create(
      name: '詠み人知らず',
      email: SecureRandom.alphanumeric(10) + '@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
    auto_login(@guest_user)
    redirect_back_or_to root_path, notice: 'ゲストユーザーとしてログインしました'
  end
end
