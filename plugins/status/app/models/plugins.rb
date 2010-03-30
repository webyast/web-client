class Plugins < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.system.plugins"
end
