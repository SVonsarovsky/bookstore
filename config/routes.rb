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
  get    '/shop/:category_id', to: 'books#index'

  get    '/books/:id', to: 'books#show', as: 'book'
  get    '/books/:book_id/add-review', to: 'reviews#new', as: 'add_review'
  post   '/books/:book_id/create-review', to: 'reviews#create', as: 'create_review'

  get    '/cart', to: 'orders#cart'
  post   '/cart/add', to: 'orders#add_item'
  put    '/cart/update', to: 'orders#update_cart'
  delete '/cart/remove/:item_id', to: 'orders#remove_item', as: 'cart_remove'
  delete '/cart/empty', to: 'orders#empty_cart'

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
