Rails.application.routes.draw do
  resources :pay_accounts
  get 'root/index'
  root to: 'root#index'

  resources :expenses
  resources :stores
  resources :receipt_details
  resources :receipts
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'receipts/xml_upload', to: 'receipts#xml_upload'
  post 'receipts/csv_upload', to: 'receipts#csv_upload'

  post 'receipt_details/xml_upload', to: 'receipt_details#xml_upload'
  post 'receipt_details/csv_upload', to: 'receipt_details#csv_upload'
end
