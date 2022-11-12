module Authentication
  extend ActiveSupport::Concern

  included do

    private

      def current_user
        if session[:user_id].present?
          @current_user ||= User.find_by(id: session[:user_id]).decorate
        # Если в сессии ничего нет, то мы смотрим, а не запоминали ли мы этого юзера раньше?
        elsif cookies.encrypted[:user_id].present?
          user = User.find_by(id: cookies.encrypted[:user_id])
          # Дальше нам надо проверить, соответствует ли токен из куки токену в БД
          if user&.remember_token_authenticated?(cookies.encrypted[:remember_token])
            # Установим в сессию эту штуку, чтобы потом последующие проверки выполнялись быстрее:
            sign_in(user)
            @current_user ||= user.decorate
          end
        end
      end

      def user_signed_in?
        current_user.present?
      end

      def require_no_authentication
        return if !user_signed_in?

        flash[:warning] = "You are already signed in!"
        redirect_to root_path
      end

      def require_authentication
        return if user_signed_in?

        flash[:warning] = "You are not signed in!"
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

      def sign_out
        session.delete(:user_id)
        @current_user = nil
      end

      helper_method :current_user, :user_signed_in?
  end
end
