class Group < YaST::ServiceResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.groups"
  attr_accessor :type,
                :grp_string
end
