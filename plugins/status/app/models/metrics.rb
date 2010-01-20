class Metrics < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.system.metrics"
end
