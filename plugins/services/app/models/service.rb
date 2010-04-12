class Service < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.services"

  def enabled?
    return self.enabled == "true"
  end

  def custom?
    return self.custom == "true"
  end
end
