# frozen_string_literal: true

module Rememberable
  extend ActiveSupport::Concern

  included do
    attr_accessor :remember_token

    def remember_me
      # Генерируем токен
      self.remember_token = SecureRandom.urlsafe_base64

      # Отключаем временно проверку Rubocop'а Rails/SkipsModelValidations

      # Кладем в таблицу Users дайджест токена (хэшированного токена). Нужно прям со значком коммента
      # rubocop:disable Rails/SkipsModelValidations

      update_column :remember_token_digest, digest(remember_token)

      # Включаем обратно проверку Rubocop'а Rails/SkipsModelValidations. Нужно прям со значком коммента
      # rubocop:enable Rails/SkipsModelValidations
    end

    def forget_me
      # rubocop:disable Rails/SkipsModelValidations
      update_column :remember_token_digest, nil
      # rubocop:enable Rails/SkipsModelValidations
      self.remember_token = nil
    end

    def remember_token_authenticated?(remember_token)
      return false if remember_token_digest.blank?

      BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
    end
  end
end
