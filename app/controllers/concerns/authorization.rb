# frozen_string_literal: true

module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:danger] = t('global.flash.not_authorized')
      # Куда делается редирект:
      # - либо туда, где юзер был до попытки выполнения действия (если request.referer есть)
      # - если его нет, то просто на заглавную страницу
      redirect_to(request.referer || root_path)
    end
  end
end
