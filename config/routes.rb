Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "sessions#root"

  post "users", to: "users#create"
  post "users/login", to: "sessions#login"

end
