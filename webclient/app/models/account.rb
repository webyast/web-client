#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++


require 'uri'
require 'digest/sha1'
require 'yast/service_resource'

class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 1..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 1..40
  validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :password

  # Authenticates a user by their login name and unencrypted password to host.
  # Returns pair of [ account, token ]
  #
  # Will raise unless uri is a valid uri or if target host is blocked by
  # failed attempt to login
  #
  def self.authenticate(login, passwd, uri_s)
    # host is just a hostname, and we want to set the
    # HTTP client REST proxy URL to that host, so we need
    # to add http
    #
    # in the future, if we use other protocols via a client
    # proxy, we need to set the right url there too

    # Ensure that we really have a http/https uri
    uri = URI.parse(uri_s.to_s)
    
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise "service should be a http or https URI"
    end

    # set default site url for all YaST service based resources
    YaST::ServiceResource::Session.site = uri
    YaST::ServiceResource::Session.login = login
    
    YaST::ServiceResource::Base.password = ""
    YaST::ServiceResource::Session.auth_token = ""

    # the above will obsolete this
    YaST::ServiceResource::Base.site = uri
    # create a login resource
    ret = YaST::ServiceResource::Login.create(:login => login, :password =>passwd, :remember_me => true)
    # this would log the password!
    # logger.debug ret.inspect
    if (ret and ret.attributes["login"] == "granted")
      @password = passwd
      acc = find_by_login(login)
      if !acc
        acc = Account.new
        acc.login = login
      end
      @password = passwd
      acc.password = passwd
      acc.save
      Rails.logger.info "Authenticate Successful for rest-server ID #{ret.attributes["auth_token"].attributes["value"].inspect}"
      YaST::ServiceResource::Base.password = ret.attributes["auth_token"].attributes["value"]
      YaST::ServiceResource::Session.auth_token = ret.attributes["auth_token"].attributes["value"]
      return acc, ret.attributes["auth_token"].attributes["value"]
    elsif (ret && ret.attributes["login"] == "blocked")
      raise BlockedService.new(ret.attributes["remain"])
    else
      Rails.logger.error "Authenticate Failure"
      return nil, nil
    end
  end

  class BlockedService < RuntimeError
    attr_accessor :time

    def initialize(time)
      @time = time
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(data, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{data}--")
  end

  # Encrypts the data with the user salt
  def encrypt(data)
    self.class.encrypt(data, salt)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
#    remember_me_for 2.weeks
    remember_me_for 1.days
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil

    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    end
      
    def password_required?
      !password.blank?
    end

end
