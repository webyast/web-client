class Status < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.system.status"
end
