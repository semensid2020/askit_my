# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  # Проверяем что юзер не вошел на сайт, т.к. вошедшему юзеру нет смысла давать сбрасывать пароль данным способом
  # он его можно просто поменять в настройках УЗ
  before_action :require_no_authentication

end
