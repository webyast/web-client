class InsertLocalhost < ActiveRecord::Migration
  def self.up
    Host.create(
    :url => 'http://localhost:8080',
    :name => 'localhost',
    :updated_at => Time.now.utc,
    :description => 'Local server',
    :created_at => Time.now.utc
    )
  end

  def self.down
    host = Host.find_by_name('localhost')
    host.destroy
  end
end
