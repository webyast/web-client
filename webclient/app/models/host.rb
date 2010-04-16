require 'uri'

class Host < ActiveRecord::Base
  validates_presence_of :name, :url
  validates_format_of :url, :with => URI.regexp
  validates_uniqueness_of :name

  def self.find_by_id_or_name id_or_name
    host = Host.find(id_or_name) rescue nil
    unless host
      host = Host.find_by_name(id_or_name) rescue nil
    end
    host
  end
end
