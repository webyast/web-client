ActionController::Routing::Routes.draw do |map|
  map.connect "/system", :controller => 'system', :action => 'index'
end

