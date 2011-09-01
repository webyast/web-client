require 'yast/service_resource'
require 'example'

class ExampleController < ApplicationController
  before_filter :login_required, :prepare

 private

  def prepare
    @permissions = Example.permissions
  end

public

  # GET /example
  # GET /example.xml
  def index
    @example = Example.find (:one)
  end

end


