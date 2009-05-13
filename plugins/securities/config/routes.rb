ActionController::Routing::Routes.draw do |map|
  map.connect "/security", :controller => 'securities', :action => 'index'
  map.connect "/security/update", :controller => 'securities', :action => 'commit'

end

