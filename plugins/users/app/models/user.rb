class User < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.users"
  attr_accessor :type,
                :grp_string
end
