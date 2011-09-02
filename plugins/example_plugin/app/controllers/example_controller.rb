require 'yast/service_resource'
require 'example'

class ExampleController < ApplicationController
  before_filter :login_required, :read_permissions

private

  def read_permissions
    @permissions = Example.permissions
  end

public

  # Initialize GetText and Content-Type.
  init_gettext "webyast-example-ui"

  # GET /example
  def index
    @example = Example.find(:one)
  end

  # PUT /example
  def update
    @example = Example.find(:one)
    @example.content = params["example"]["content"]
    begin
      @example.save
      flash[:notice] = _("File saved")
    rescue Exception => error
      flash[:error] = _("Error while saving file: %s") % error.inspect
    end
    render :index
  end

end


