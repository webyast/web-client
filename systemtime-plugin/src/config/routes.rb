ActionController::Routing::Routes.draw do |map|
  map.connect "/systemtime", :controller => 'systemtime', :action => 'index'
end

