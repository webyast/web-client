
require 'digest/sha1'
class Account < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, passwd)
     l = Login.new()
     l.initServiceUrl("http://localhost:3001")
     ret = Login.create(:login => login, :password =>passwd, :remember_me => "1")
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
	puts "Authenticate Successful for rest-server ID #{ret.attributes["auth_token"].attributes["value"].inspect}"
        l.setWebServiceAuth(ret.attributes["auth_token"].attributes["value"])
        return acc, ret.attributes["auth_token"].attributes["value"]
     else
  	puts "Authenticate Failure"
        l.setWebServiceAuth("")
        return nil, nil
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
