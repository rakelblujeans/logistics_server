Rails.application.routes.draw do
  resources :providers

  get 'home/index'

  resources :credit_cards

  resources :customers

  resources :delivery_types

  resources :events

  resources :event_states

  resources :languages

  get 'orders/unverified' => 'orders#unverified'
  post 'orders/assignDevice' => 'orders#assignDevice'
  delete 'orders/unassignDevice' => 'orders#unassignDevice'
  post 'orders/markVerified' => 'orders#markVerified'
  resources :orders

  get 'phones/inventorySnapshot/:order_id'  => 'phones#inventorySnapshot'
  get 'phones/assignedInventory/:order_id'  => 'phones#assignedInventory'
  get 'phones/availableInventory'     => 'phones#availableInventory'
  resources :phones

  resources :providers

  resources :receipts

  resources :shipments
  
  match '*any' => 'application#options', :via => [:options]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

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
