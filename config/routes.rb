# frozen_string_literal: true

require 'sidekiq/web'

class AdminConstraint
  # Принимает запрос, который был отправлен
  def matches?(request)
    user_id = request.session[:user_id] || request.cookie_jar.encrypted[:user_id]

    User.find_by(id: user_id)&.admin_role?
  end
end

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq', constraints: AdminConstraint.new

  concern :commentable do
    resources :comments, only: %i[create destroy]
  end

  namespace :api do
    resources :tags, only: :index
  end

  # Например: localhost/en/questions, при этом локаль НЕобязательна в УРЛе
  scope '(:locale)', locale: /#{I18n.available_locales.join("|")}/ do
    # resources - когда routes ожидает для некоторых маршрутов присутствие id-шника (видимо, когда сущностей м.б. много)
    # resource  - если хотим, чтобы идентификаторов никаких не было.
    resource :session, only: %i[new create destroy]

    resource :password_reset, only: %i[new create edit update]

    resources :users, only: %i[new create edit update]

    resources :questions, concerns: :commentable do
      # Вложенный маршрут для ответов, т.к. они относятся к вопросу
      resources :answers, except: %i[new show]
    end

    # Комменты к ответам пришлось выделить отдельно, чтобы более-менее удобный и не сильно длинный маршрут к ним был.
    # (поэтому вот такой дубль стр.14 появился ниже:)
    resources :answers, except: %i[new show], concerns: :commentable

    namespace :admin do
      resources :users, only: %i[index create edit update destroy]
    end

    root 'pages#index'
  end
end
