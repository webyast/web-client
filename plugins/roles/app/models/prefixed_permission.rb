class PrefixedPermission
  attr_accessor :prefix, :short_name, :full_name, :description

  def initialize(permission, description="")
    p = permission
    @full_name = p
    @description = description
    splitted = p.split(".")
    if splitted.length > 1 then
      @prefix = splitted[0..-2].join(".")
      @short_name = splitted.last
    else
      @prefix = p
      @short_name = p
    end
  end
end

class PrefixedPermissions < Hash
  def initialize(prefixed_permissions)
    self.clear
    prefixed_permissions.each do |p|
      if self[p.prefix]
        self[p.prefix] <<  p
      else
        self[p.prefix] = [p]
      end
    end
  end
end
