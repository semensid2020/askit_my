# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :require_no_authentication, only: %i[new create]
  before_action :require_authentication, only: :destroy

  def new; end

  def create
    user = User.find_by(email: params[:email])
    #  TODO разобрать
    # user& - если user -> nil, то сразу переходим в else.
    if user&.authenticate(params[:password])
      sign_in(user)
      remember(user) if params[:remember_me] == '1'
      flash[:success] = "Welcome back, #{current_user.name_or_email}!"
      redirect_to root_path
    else
      #  TODO разобрать
      #  Почему flash.now требует render :new?
      flash.now[:warning] = 'Incorrect email and/or password!'
      render :new
    end
  end

  def destroy
    sign_out
    flash[:success] = 'See you later!'
    redirect_to root_path
  end
end
