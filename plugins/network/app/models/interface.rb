class Interface < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.network.interfaces"
end
