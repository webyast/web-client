ActionController::Routing::Routes.draw do |map|

  map.resources :webservices
  map.resource :session

  map.root :controller => "main"
  
  map.login '/login', :controller => 'session', :action => 'new'
  map.logout '/logout', :controller => 'session', :action => 'destroy'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
