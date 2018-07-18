Rails.application.routes.draw do
  get 'root/index'
  root to: 'root#index'

  resources :expenses
  resources :stores
  resources :receipt_details
  resources :receipts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
