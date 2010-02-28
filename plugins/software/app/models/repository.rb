class Repository < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.system.repositories'

end
