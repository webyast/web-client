class Logs < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.system.logs"
end
