class Ntp < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.ntp"

  def available?
     ret = actions.respond_to? :synchronize
     Rails.logger.info "ntp available : #{ret}"
     return ret
  end
end
