Rails.application.routes.draw do
  root to: 'home#index'
  devise_for :authors

  get '/logout', to: 'application#logout', as: :logout_author
  get '/login', to: 'application#login', as: :login_author

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
