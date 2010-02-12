class Ntp < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.ntp"

  def available?
     ret = actions.respond_to? :synchronize
     Rails.logger.info "ntp available : #{ret}"
     return ret
  end

  def Ntp.available? #class method
    begin
      unless Ntp.permissions[:available] && Ntp.permissions[:synchronize]
        Rails.logger.info "ntp doesn't have permissions available :  #{Ntp.permissions[:available]} synchronize: #{Ntp.permissions[:synchronize]}"
        return false
      end
      ntp = Ntp.find :one
      return ntp.available?
    rescue Exception => e #available call, so don't show anything, just log
      Rails.logger.warn e
      return false
    end
  end
end
