# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ErrorHandling
  include Authentication

  around_action :switch_locale

  private

  def switch_locale(&action)
    locale = locale_from_url || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def locale_from_url
    locale = params[:locale]
    # Каждую локаль приведем к строке - .map(&:to_s):
    # потому что строку и символ сравнивать нельзя
    return locale if I18n.available_locales.map(&:to_s).include?(locale)
    # Если запрошенную локаль мы не поддерживаем, тогда мы возвращаем просто nil
    nil
  end

  # Встроенный в RoR метод, который мы переопределим
  # по дефолту в параметрах запроса передается текущая локаль, если не указано иное 
  def default_url_options
    { locale: I18n.locale }
  end

end
