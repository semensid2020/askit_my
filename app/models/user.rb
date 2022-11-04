class User < ApplicationRecord
  attr_accessor :old_password

  validates :email, presence: true, uniqueness: true

  # Ставим false, т.к. все валидации будем прописывать сами.
  has_secure_password validations: false
  validates :password, confirmation: true, allow_blank: true, length: {minimum: 8, maximum: 70}

  #  Слово validate требует выполнения указанного метода (кастомная валидация)
  validate :password_presense
  validate :password_complexity


  private

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
