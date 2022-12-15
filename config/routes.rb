# frozen_string_literal: true

Rails.application.routes.draw do
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

    resources :users, only: %i[new create edit update]

    resources :questions, concerns: :commentable do
      # Вложенный маршрут для ответов, т.к. они относятся к вопросу
      resources :answers, except: %i[new show]
    end

    # Комменты к ответам пришлось выделить отдельно, чтобы более-менее удобный и не сильно длинный маршрут к ним был.
    # (поэтому вот такой дубль стр.14 появился ниже:)
    resources :answers, except: %i[new show], concerns: :commentable

    namespace :admin do
      resources :users, only: %i[index create]
    end

    root 'pages#index'
  end
end
