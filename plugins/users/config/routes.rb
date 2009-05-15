ActionController::Routing::Routes.draw do |map|
  #map.resources :users
  map.resources :users, :member => { :exportssh => :get }
  map.connect "/users/:users_id/exportssh", :controller => 'users', :action => 'sshexport'
end
