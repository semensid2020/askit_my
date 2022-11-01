Rails.application.routes.draw do
  resources :users, only: %i[new create]

  resources :questions do
    # Вложенный маршрут для ответов, т.к. они относятся к вопросу
    resources :answers, except: %i[new show]
  end

  root 'pages#index'
end
