class CreateWebservices < ActiveRecord::Migration
  def self.up
    create_table :webservices do |t|
      t.string :name
      t.text :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :webservices
  end
end
