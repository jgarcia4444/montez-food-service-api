Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "sessions#root"

  post "users", to: "users#create"
  post "users/login", to: "sessions#login"

  post "users/forgot-password", to: "users#forgot_password"
  post "users/forgot-password/check-code", to: "users#check_code"
  patch "users/forgot-password/change-password", to: "users#change_password"

  get 'order-online/fetch-suggestions/:item_query', to: "order_items#fetch_suggestions"

  post 'order-online/orders', to: "user_orders#persist_order"
  post 'users/verify', to: "users#verify_user"
  post 'addresses/:email', to: "addresses#create"

  delete 'users/:email/addresses/:address_id', to: "addresses#destroy"

  post "users/admin/login", to: "admins#login"

  get "pending-orders", to: "admins#pending_orders_index"
  get "users/admin/pending-order/:order_id", to: "admins#pending_order_show"
  post "users/admin/confirm-order", to: "admins#confirm_pending_order"

  post 'pending-orders/delete', to: "pending_orders#cancel_order"

  get 'admin/get-client-details/:admin_username', to: "admins#pass_credentials"

  get 'oauth/authenticate', to: "quickbooks#authenticate"
  post 'oauth/callback', to: "quickbooks#oauth_callback"

end
