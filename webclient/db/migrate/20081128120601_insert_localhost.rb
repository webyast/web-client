class InsertLocalhost < ActiveRecord::Migration
  def self.up
    Webservice.create(
    :name => 'http://localhost:8080',
    :updated_at => Time.now.utc,
    :desc => 'Local server',
    :created_at => Time.now.utc
    )
  end

  def self.down
  end
end
