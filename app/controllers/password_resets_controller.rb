# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  # Проверяем что юзер не вошел на сайт, т.к. вошедшему юзеру нет смысла давать сбрасывать пароль данным способом
  # он его можно просто поменять в настройках УЗ
  before_action :require_no_authentication
  before_action :set_user, only: %i[edit update]

  def create
    @user = User.find_by(email: params[:email])
    # Можно было бы использовать deliver_now, но он делает это in place, и браузер может "подвиснуть".
    # deliver_later же поставит в очередь отправку письма, и она произойдет в фоновом режиме.
    # Пока мы не настроили обработчик фоновых задач (Sidekiq или др.), они deliver_later по сути аналогичен deliver_now
    # НО! Если письма отправляются ИЗ самих фоновых задач, то надо ставить deliver_now
    if @user.present?
      @user.set_password_reset_token

      PasswordResetMailer.with(user: @user).reset_email.deliver_later
    end

    flash[:success] =t('.success')
    redirect_to new_session_path
  end

  def edit;end

  def update
    if @user.update(user_params)
      flash[:success] =t('.success')
      redirect_to new_session_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation).merge(admin_edit: true)
  end

  def set_user
    redirect_to(new_session_path, flash: { warning: t('password_resets.fail') }) and return unless params[:user].present?

    @user = User.find_by email: params[:user][:email],
                         password_reset_token: params[:user][:password_reset_token]

    # Не стоит делать так, чтобы этот токен имел неограниченный срок действия.
    # Поэтому делает редирект, если не получилось вообще найти пользователя, или истек срок жизни токена
    redirect_to(new_session_path, flash: { warning: t('password_resets.fail') }) unless @user&.password_reset_period_valid?
  end
end
