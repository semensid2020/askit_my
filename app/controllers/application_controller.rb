# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ErrorHandling
  include Authentication

  around_action :switch_locale

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
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

end
