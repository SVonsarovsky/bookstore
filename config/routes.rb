Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :admins
  mount RailsAdmin::Engine => '/admins', as: 'rails_admin'
  devise_for :users
  devise_scope :user do
    get  '/sign-up' => 'devise/registrations#new'
    get  '/sign-in' => 'devise/sessions#new'
    get  '/sign-out' => 'devise/sessions#destroy'
  end

  root   'pages#home'
  get    '/shop', to: 'books#index'
  get    '/shop/:category_id', to: 'books#index', as: 'shop_category'
  resources :books, only: [:show] do
    resources :reviews, only: [:new, :create]
  end

  get    '/cart/checkout(/:step)', to: 'carts#checkout', as: 'cart_checkout', step: /[2-5]{1}/
  delete '/cart/:item_id', to: 'carts#remove_item', as: 'cart_item'
  resource  :cart, only: [:create, :show, :update, :destroy]
  resource  :user, only: [:edit, :update, :destroy]
  resources :orders, only: [:index, :show]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
