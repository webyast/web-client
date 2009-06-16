ActionController::Routing::Routes.draw do |map|
  map.connect "/network", :controller => 'network', :action => 'index'
end
