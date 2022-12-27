# frozen_string_literal: true

module Recoverable
  extend ActiveSupport::Concern

  included do
    # Вызывается перед обновлением записи, но после того как валидации прошли
    # password_digest_changed - доступен, потому что в БД есть колонка password_digest
    # :password_digest_changed? - был ли изменен digest в рамках текущей операции с БД
    # т.е. если password_digestизменился, то сбрасываем данные о токене в clear_reset_password_token
    before_update :clear_reset_password_token, if: :password_digest_changed?

    def set_password_reset_token
      # Для генерации токенов задействуем комбинацию уже имеющегося функционала def digest и SecureRandom
      update(password_reset_token: digest(SecureRandom.urlsafe_base64),
             password_reset_token_sent_at: Time.current)
    end

    def clear_reset_password_token
      self.password_reset_token = nil
      self.password_reset_token_sent_at = nil
    end

    def password_reset_period_valid?
      # Проверяем что токен вообще есть и устанавливаем время действия в 1 час
      password_reset_token_sent_at.present? && Time.current - password_reset_token_sent_at <= 60.minutes
    end
  end
end
