Rails.application.routes.draw do

  resources :uploaded_files
  devise_for :users
  root to: 'application#index.html'
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show]

end
