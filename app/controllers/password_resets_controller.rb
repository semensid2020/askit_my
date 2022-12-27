# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  # Проверяем что юзер не вошел на сайт, т.к. вошедшему юзеру нет смысла давать сбрасывать пароль данным способом
  # он его можно просто поменять в настройках УЗ
  before_action :require_no_authentication

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
end
