ActionController::Routing::Routes.draw do |map|
  map.connect "/systemtime", :controller => 'system_time', :action => 'index'
end

