class User < ApplicationRecord
  attr_accessor :old_password, :remember_token

  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true

  # Ставим false, т.к. все валидации будем прописывать сами.
  has_secure_password validations: false
  validates :password, confirmation: true, allow_blank: true, length: {minimum: 8, maximum: 70}

  #  Слово validate требует выполнения указанного метода (кастомная валидация)
  validate :password_presense
  validate :password_complexity

  # Только при обновлении записи.
  validate :correct_old_password, on: :update, if: -> { password.present? }

  def remember_me
    # Генерируем токен
    self.remember_token = SecureRandom.urlsafe_base64
    # Кладем в таблицу Users дайджест токена (хэшированного токена)
    update_column :remember_token_digest, digest(remember_token)
  end

  def forget_me
    update_column :remember_token_digest, nil
    self.remember_token = nil
  end

  def remember_token_authenticated?(remember_token)
    return false unless remember_token_digest.present?

    BCrypt::Password.new(remember_token_digest).is_password?(remember_token)
  end

  private

    # Заимствовано из has_secure_password.
    # Создается хэш с определенной сложностью (cost):
    def digest(string)
      cost = ActiveModel::SecurePassword.
        min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def correct_old_password
      # password_digest_was - специальный метод RoR, который вытаскивает именно старый хэширован.пароль
      # а не новый, который хранится в памяти
      return if BCrypt::Password.new(password_digest_was).is_password?(old_password)

      errors.add(:old_password, 'is incorrect')
    end

    def password_complexity
      # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
      return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

      errors.add :password, 'complexity requirement not met. Length should be 8-70 characters and include: 1 uppercase, 1 lowercase, 1 digit and 1 special character'
    end

    # Пароль можно указывать или нет, но только если какой-то пароль уже был задан ранее (т.е. не этап регистрации)
    def password_presense
      errors.add(:password, :blank) unless password_digest.present?
    end

end
