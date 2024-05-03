Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root to: "top#index"
  resources :users, only: %i[new create]
  get 'login' => 'user_sessions#new', as: :login
  post 'login' => 'user_sessions#create'
  delete 'logout' => 'user_sessions#destroy', as: :logout
  get 'first_login_page' => 'user_sessions#first_login_page', as: :first_login_page
  post '/guest_login' => 'user_sessions#guest_login', as: :guest_login
  resources :posts, only: %i[new] do
    post 'generate_tanka', on: :collection
    get 'generate_tanka', on: :collection
    get 'current_user_page', on: :collection
  end
  resources :posts
  get 'terms', to: 'pages#terms'
end
