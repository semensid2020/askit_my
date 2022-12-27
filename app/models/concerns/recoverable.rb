# frozen_string_literal: true

module Recoverable
  extend ActiveSupport::Concern

  included do
    def set_reset_password_token
      # Для генерации токенов задействуем комбинацию уже имеющегося функционала def digest и SecureRandom
      update(password_reset_token: digest(SecureRandom.urlsafe_base64),
             password_reset_token_sent_at: Time.current)
    end
  end
end
