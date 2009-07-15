require 'uri'

class Host < ActiveRecord::Base
  validates_format_of :url, :with => URI.regexp
  validates_uniqueness_of :name
end
