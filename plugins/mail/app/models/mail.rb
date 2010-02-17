class Mail < YaST::ServiceResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.mailsettings"
end
