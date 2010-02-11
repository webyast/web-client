class Administrator < YaST::ServiceResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.administrator"
end
