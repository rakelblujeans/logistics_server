Rails.application.routes.draw do
  resources :providers

  get 'home/index'
  get 'home/search'

  resources :delivery_types

  resources :events

  resources :event_states

  resources :languages

  get  'orders/unverified'        => 'orders#unverified'
  get  'orders/verified'          => 'orders#verified'
  post 'orders/assign_device'     => 'orders#assign_device'
  post 'orders/unassign_device'   => 'orders#unassign_device'
  post 'orders/mark_verified'     => 'orders#mark_verified'
  get  'orders/incoming_on'       => 'orders#incoming_on'
  get  'orders/outbound_on'       => 'orders#outbound_on'
  get  'orders/currently_out'     => 'orders#currently_out'
  post 'orders/mark_complete'     => 'orders#mark_complete'
  get  'orders/overdue'           => 'orders#overdue'
  get  'orders/overdue_shipping'  => 'orders#overdue_shipping'
  get  'orders/missing_phones'    => 'orders#missing_phones'
  get  'orders/warnings'          => 'orders#warnings'
  put  'orders/:id/toggle_activation' => 'orders#toggle_activation'
  resources :orders

  get  'phones/available_inventory'   => 'phones#available_inventory'
  get  'phones/:id/upcoming_orders'   => 'phones#upcoming_orders'
  get  'phones/:id/current_order'     => 'phones#current_order'
  post 'phones/check_in'              => 'phones#check_in'
  put  'phones/:id/toggle_activation' => 'phones#toggle_activation'
  resources :phones

  resources :providers

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
