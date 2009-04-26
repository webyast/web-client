ActionController::Routing::Routes.draw do |map|

  #map.resources :patch_updates, :collection => { :list => :get }, :member => { :install => :put }
  
#  map.connect "/patch_updates", :controller => 'patch_updates', :action => 'show'
#  map.connect "/patch_updates/patchlist", :controller => 'patch_updates', :action => 'patchlist'
  
#  map.connect "/patch_updates/install/:id", :controller => 'patch_updates', :action => 'install'
end
