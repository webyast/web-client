
# class for reading control panel configuration
# which is stored in /etc/webyast/control_panel.yml file
# The config file contains a single hash in YAML format.
class ControlPanelConfig

  # read a single value or complete control panel configuration
  # arguments:
  #   attribute => requested attribute name,
  #     if nil complete config is returned
  #   default_value => default value for the requested attribute,
  #     used when the attribute is missing or when an error occurrs
  #     during reading/parsing the config file
  def self.read(attribute = nil, default_value = nil)
    begin
      l = YAML::load_file '/etc/webyast/control_panel.yml'

      # no required attribute, return complete config
      return l if attribute.nil?

      # return requested attribute if present
      if l.has_key? attribute
        return l[attribute]
      end

      # return default for missing value
      Rails.logger.warn "Cannot read attribute '#{attribute}', using default: #{default_value}"
      return default_value
    rescue Exception => e
      Rails.logger.error "Cannot read /etc/webyast/control_panel.yml: #{e}"
      return default_value
    end
  end
end
