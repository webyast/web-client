ActionController::Routing::Routes.draw do |map|

  map.resources :hosts
  map.resource :session

  map.root :controller => "main"
  
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
