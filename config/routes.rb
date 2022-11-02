Rails.application.routes.draw do
  # resources - когда routes ожидает для некоторых маршрутов присутствие id-шника (видимо, когда сущностей м.б. много)
  # resource  - если хотим, чтобы идентификаторов никаких не было.
  resource :session, only: %i[new create destroy]

  resources :users, only: %i[new create]

  resources :questions do
    # Вложенный маршрут для ответов, т.к. они относятся к вопросу
    resources :answers, except: %i[new show]
  end

  root 'pages#index'
end
