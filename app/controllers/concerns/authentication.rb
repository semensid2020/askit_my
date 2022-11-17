# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  # rubocop:disable Rails/BlockLength
  included do
    private

    def current_user
      user = session[:user_id].present? ? user_from_session : user_from_token
      # Если в сессии ничего нет, то мы смотрим, а не запоминали ли мы этого юзера раньше (есть кука)?
      # TODO разобраться почему у меня никогда не удаляются данные о сессии после перезапуска браузера
      # таким образом, я никогда не доходим до user_from_token
      @current_user ||= user&.decorate # Проверяем что юзер не nil !
    end

    def user_from_session
      User.find_by(id: session[:user_id])
    end

    def user_from_token
      user = User.find_by(id: cookies.encrypted[:user_id])
      token = cookies.encrypted[:remember_token]
      # Дальше нам надо проверить, соответствует ли токен из куки токену в БД
      return unless user&.remember_token_authenticated?(token)

      # Установим в сессию эту штуку, чтобы потом последующие проверки выполнялись быстрее:
      sign_in(user)
      user
    end

    def user_signed_in?
      current_user.present?
    end

    def require_no_authentication
      return unless user_signed_in?

      flash[:warning] = 'You are already signed in!'
      redirect_to root_path
    end

    def require_authentication
      return if user_signed_in?

      flash[:warning] = 'You are not signed in!'
      redirect_to root_path
    end

    def sign_in(user)
      session[:user_id] = user.id
    end

    def remember(user)
      user.remember_me
      # https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html - почитать
      cookies.encrypted.permanent[:remember_token] = user.remember_token
      cookies.encrypted.permanent[:user_id] = user.id
    end

    def forget(user)
      user.forget_me
      # Удаляем из кукис данные о юзере, т.к. в БД у нас больше никаких токенов нету
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end

    def sign_out
      forget(current_user)
      session.delete(:user_id)
      @current_user = nil
    end

    helper_method :current_user, :user_signed_in?
  end
  # rubocop:enable Rails/BlockLength
end
