Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "sessions#root"

  post "users", to: "users#create"
  post "users/login", to: "sessions#login"

  post "users/forgot-password", to: "users#forgot_password"
  post "users/forgot-password/check-code", to: "users#check_code"
  post "users/forgot-password/change_password", to: "users#change_password"


end
