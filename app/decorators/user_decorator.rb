class UserDecorator < ApplicationDecorator
  # Делегирует неизвестные методы объекту, который мы "декорируем"
  delegate_all

  def name_or_email
    return name if name.present?

    email.split('@')[0]
  end
end
