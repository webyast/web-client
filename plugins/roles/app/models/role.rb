class Role < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.roles"
end
