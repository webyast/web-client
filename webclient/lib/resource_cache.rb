class ResourceCache
  include Singleton

  def resources
    str = Rails.cache.read "resources|#{site}"
    if str.blank?
        Rails.logger.debug "resource cache reload"
        reload_resources
        str = Rails.cache.read "resources|#{site}"
    end
    result = {}
    t = str.split(",").collect{ |s| YastModel::Resource.load_from_string s }
    t.each { |r| result[r.interface.to_sym] = r }
    result
  end

  def permissions
    str = Rails.cache.read "permissions|#{user}|#{site}"
    if str.blank?
        Rails.logger.debug "permissions cache reload"
        reload_permissions
        str = Rails.cache.read "permissions|#{user}|#{site}"
    end
    str.split(",").collect{ |s| YastModel::Permission.load_from_string s }
  end

private

  def resources=(resources)
    str = resources.collect { |r| r.serialize_to_string }.join ","
    Rails.cache.write "resources|#{site}", str
  end

  def reload_resources
    YastModel::Resource.site = site
    self.resources = YastModel::Resource.find(:all)
  end

  def permissions=(resources)
    str = resources.collect { |r| r.serialize_to_string }.join ","
    Rails.cache.write "permissions|#{user}|#{site}", str
  end

  def reload_permissions
    YastModel::Permission.site = site
    YastModel::Permission.password = token
    self.permissions =  YastModel::Permission.find(:all,:params => {:user_id => user})
  end

  def site
    YaST::ServiceResource::Session.site
  end

  def user
    YaST::ServiceResource::Session.login
  end

  def token
    YaST::ServiceResource::Session.auth_token
  end
end
