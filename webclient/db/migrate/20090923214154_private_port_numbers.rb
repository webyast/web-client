class PrivatePortNumbers < ActiveRecord::Migration
  def self.change(from, to)
    rx = Regexp.new "(//[^/]*:)#{from}"
    Host.find(:all).each do |h|
      next unless rx =~ h.url
      h.update_attribute :url, h.url.sub(rx, "\\1#{to}")
    end
  end

  # 54984 is for web-client (this app) but the target is rest-service: 4984
  def self.up
    change "8080", "4984"
  end

  def self.down
    change "4984", "8080"
  end
end
