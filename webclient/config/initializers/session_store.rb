# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => '_web-client_session',
  :secret      => 'f05944f2fa89ced61528d66622c2f5f4dded5912a1276890d2907d012c416f3a32f22dbd22f24614346c1360380dbf71a6fcbbc0e32b2d0cc6812afc623d6c41'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
