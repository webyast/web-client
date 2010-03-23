class Group < YaST::ServiceResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.groups"
  attr_accessor :type, :gid, :old_cn, :default_members, :members, :cn
end
