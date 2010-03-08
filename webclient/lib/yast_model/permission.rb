module YastModel
  # == Permission model
  # Model for permission setup on target system.
  #
  # for details see restdoc of permission service
  class Permission < ActiveResource::Base
    YAPI_STR = "org.opensuse.yast.modules.yapi."
    YAPI_LEN = YAPI_STR.size
    YSR_STR = "org.opensuse.yast.modules.ysr"
    YSR_NEW_STR = "registration"
    MAX_PERM_LEN = 512


    def pretty_id
      cutted = id
      cutted = cutted[YAPI_LEN,512] if cutted.start_with? YAPI_STR
      return cutted.gsub YSR_STR,YSR_NEW_STR
    end
  
    def self.deprettify_id (pretty_id,perms=[])
      pretty_id = pretty_id.gsub YSR_NEW_STR, YSR_STR
      perms = Permission.find(:all) if perms.empty?
      perms.collect { |p| p.id }.find { |id| id.include? pretty_id }
    end

  end

end
