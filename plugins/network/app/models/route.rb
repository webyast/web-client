# TCP/IP routes, not Rails routes
class Route < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.network.routes"
end
