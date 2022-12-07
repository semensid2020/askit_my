# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  # Делегирует неизвестные методы объекту, который мы "декорируем"
  delegate_all

  def name_or_email
    return name if name.present?

    email.split('@')[0]
  end

  def gravatar(size: 30, css_class: '')
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)

    h.image_tag("https://www.gravatar.com/avatar/#{email_hash}.jpg?s=#{size}",
                class: "rounded #{css_class}", alt: name_or_email)
  end
end
