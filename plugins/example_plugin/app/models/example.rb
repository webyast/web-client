class Example < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.system.example"
end
