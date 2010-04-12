class Group < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.groups"
  attr_accessor :default_members_string, :members_string
end
