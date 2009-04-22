ActionController::Routing::Routes.draw do |map|
  map.resources :webservices
  map.resources :sessions
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "main"

  map.root :controller => "controlpanel"

  # See how all your routes lay out with "rake routes"

  #login_url :controller => 'sessions', :action => 'create'
  
  map.session '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # control panel module list
  map.connect "/controlpanel/shortcuts.json", :controller => 'controlpanel', :action => 'shortcuts', :format =>'json'
  map.connect "/controlpanel/shortcuts.xml", :controller => 'controlpanel', :action => 'shortcuts', :format =>'xml'

  map.resource :config, :controller => 'config_ntp', :path_prefix => "/services/ntp"

  map.resources :patch_updates
  map.connect "/patch_updates/:id", :controller => 'patch_updates', :action => 'install'

  map.resources :users, :member => { :exportssh => :get }
  map.resources :users, :controller => 'users'
  map.connect "/users/:users_id/exportssh", :controller => 'users', :action => 'exportssh'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
