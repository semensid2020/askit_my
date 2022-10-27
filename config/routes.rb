Rails.application.routes.draw do

  resources :questions do
    # Вложенный маршрут для ответов, т.к. они относятся к вопросу
    resources :answers, only: %i[create destroy]
  end

  root 'pages#index'
end
