ActionController::Routing::Routes.draw do |map|
  map.connect "/security", :controller => 'securities', :action => 'create'
  map.connect "/security/show", :controller => 'securities', :action => 'show'
  map.connect "/security/update", :controller => 'securities', :action => 'update'

end

