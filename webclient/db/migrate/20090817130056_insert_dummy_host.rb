class InsertDummyHost < ActiveRecord::Migration
  def self.up
    Host.create(
    :url => 'http://localhost:4567',
    :name => 'dummy-host',
    :updated_at => Time.now.utc,
    :description => 'Dummy REST service(host)',
    :created_at => Time.now.utc
    ) if ENV['RAILS_ENV'] != 'production'
  end

  def self.down
    host = Host.find_by_name('dummy-host')
    host.destroy if host
  end
end
