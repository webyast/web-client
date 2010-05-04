#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class StatusControllerTest < ActionController::TestCase

  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    StatusController.any_instance.stubs(:login_required)
    @controller = StatusController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @response_logs = fixture "logs.xml"
    @response_logs_system = fixture "logs_system.xml"
    @response_graphs = fixture "graphs.xml"
    @response_plugins = fixture "plugins.xml"
    @response_graphs_memory = fixture "graphs_memory.xml"
    @response_graphs_disk = fixture "graphs_disk.xml"
    @response_metrics_memory_free = fixture "waerden+memory+memory-free.xml"
    @response_metrics_memory_used = fixture "waerden+memory+memory-used.xml"
    @response_metrics_memory_cached = fixture "waerden+memory+memory-used.xml"
    @response_metrics_df_root = fixture "waerden+df+df-root.xml"
    @response_metrics = fixture "metrics.xml"
    @response_writing_limits = fixture "memory_write.xml"
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.logs" => "/logs",
          :"org.opensuse.yast.system.metrics" => "/metrics",
          :"org.opensuse.yast.system.graphs" => "/graphs",
          :"org.opensuse.yast.system.plugins" => "/plugins"},
          { :policy => "org.opensuse.yast.system.status" })
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get "/plugins.xml", @header, @response_plugins, 200
      mock.get "/logs.xml", @header, @response_logs, 200
      mock.get "/logs/system.xml?lines=50&pos_begin=0", @header, @response_logs_system, 200
      mock.get "/graphs.xml?checklimits=true", @header, @response_graphs, 200
      mock.get "/graphs.xml?background=true&checklimits=true", @header, @response_graphs, 200
      mock.get "/graphs.xml", @header, @response_graphs, 200
      mock.get "/graphs/Disk.xml", @header, @response_graphs_disk, 200
      mock.get "/graphs/Memory.xml", @header, @response_graphs_memory, 200
      mock.put "/graphs/Memory.xml", @header, @response_writing_limits, 200
      mock.get "/metrics.xml", @header, @response_metrics, 200
      mock.get "/metrics/waerden+memory+memory-free.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_free, 200
      mock.get "/metrics/waerden+memory+memory-used.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_used, 200
      mock.get "/metrics/waerden+memory+memory-cached.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_cached, 200
      mock.get "/metrics/waerden+df+df-root.xml?start=1264006320&stop=1264006620", @header, @response_metrics_df_root, 200
      mock.post "/mail/state.xml", @header, nil, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  #first index call
  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
  end

  # now permissions in index
  def test_index_no_permissions
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.logs" => "/logs",
          :"org.opensuse.yast.system.metrics" => "/metrics",
          :"org.opensuse.yast.system.graphs" => "/graphs",
          :"org.opensuse.yast.system.plugins" => "/plugins"},
          { :policy => "org.opensuse.yast.system.status" })
      mock.permissions "org.opensuse.yast.system.status", { :read => false, :writelimits => false }
      mock.get   "/logs.xml", @header, @response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, @response_graphs, 200
      mock.get   "/graphs.xml", @header, @response_graphs, 200
      mock.get   "/plugins.xml", @header, @response_plugins, 200
      mock.get   "/metrics.xml", @header, @response_metrics, 200
    end

    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
    assert assigns(:permissions), "permissions is not assigned"
    assert !assigns(:permissions)[:read], "read permission is granted"
    assert !assigns(:permissions)[:writelimits], "writelimits permission is granted"
  end

  #testing show summary AJAX call; OK
  def test_show_summary
    get :show_summary
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"div",
               :attributes => { :class => "status-icon warning" }
    assert_tag "Registration is missing; Mail configuration test not confirmed"
  end

  #testing show summary AJAX call; Host is not available
  def test_show_summary
    Logs.stubs(:permissions).raises(Errno::ECONNREFUSED)
    get :show_summary
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"div",
               :attributes => { :class => "status-icon error" }
    assert_tag "Can't connect to host"
  end

  #testing show summary AJAX call; limit CPU user reached
  def test_show_summary_limit_reached
    response_graphs = fixture "graphs_limits_reached.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.logs" => "/logs",
          :"org.opensuse.yast.system.metrics" => "/metrics",
          :"org.opensuse.yast.system.graphs" => "/graphs",
          :"org.opensuse.yast.system.plugins" => "/plugins"},
          { :policy => "org.opensuse.yast.system.status" })
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, @response_logs, 200
      mock.get   "/graphs.xml?background=true&checklimits=true", @header, response_graphs, 200
      mock.get   "/graphs.xml", @header, response_graphs, 200
      mock.get   "/plugins.xml", @header, @response_plugins, 200
      mock.get   "/metrics.xml", @header, @response_metrics, 200
    end

    get :show_summary
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"div",
               :attributes => { :class => "status-icon error" }
    assert_tag "Limits exceeded for CPU/CPU-0/user; CPU/CPU-1/user; Registration is missing; Mail configuration test not confirmed"
  end

  #testing evaluate_values AJAX call
  def test_show_evaluate_values
    Time.stubs(:now).returns(Time.at(1264006620))
    get :evaluate_values,  { :group_id => "Memory", :graph_id => "Memory" } 
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"script",
               :attributes => { :type => "text/javascript" }
  end

  #testing evaluate_values AJAX call
  def test_show_evaluate_values_with_other_id
    Time.stubs(:now).returns(Time.at(1264006620))
    get :evaluate_values,  { :group_id => "Disk", :graph_id => "root" } 
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"script",
               :attributes => { :type => "text/javascript" }
  end

  #testing confirming status
  def test_confirm_status
    post :confirm_status, { :param=>"Test mail received", :url=>"/mail/state", } 
    assert_response :redirect
  end

  #testing confirming status without param
  def test_confirm_status_without_param
    post :confirm_status, { } 
    assert_response 500
  end

  #testing  call ajax_log_custom
  def test_show_ajax_log_custom
    get :ajax_log_custom, { :id => "system", :lines => "50" } 
    assert_response :success
    assert_valid_markup
    assert_tag "\nJan 28 12:04:27 f95 avahi-daemon[9245]: Received response from host 10.10.4.228 with invalid source port 33184 on interface 'eth0.0'\nJan 28 12:04:28 f95 avahi-daemon[9245]: Received response from host 10.10.4.228 with invalid source port 33184 on interface 'eth0.0'\n\n"
  end

  #testing  call ajax_log_custom
  def test_show_ajax_log_custom_without_params
    get :ajax_log_custom, { } 
    assert_response 500
  end


  # status module must survive collectd out of sync
  def test_collectd_out_of_sync
    response_graphs = fixture "out_sync_error.xml"
    response_metrics = fixture "out_sync_error.xml"
    response_logs = fixture "logs.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.logs" => "/logs",
          :"org.opensuse.yast.system.metrics" => "/metrics",
          :"org.opensuse.yast.system.graphs" => "/graphs",
          :"org.opensuse.yast.system.plugins" => "/plugins"},
          { :policy => "org.opensuse.yast.system.status" })
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 503
      mock.get   "/graphs.xml", @header, response_graphs, 503
      mock.get   "/plugins.xml", @header, @response_plugins, 200
      mock.get   "/metrics.xml", @header, response_metrics, 503
    end

    get :index
    assert_response :success
    assert_valid_markup
    assert_tag "Collectd is out of sync. Status information can be expected at Wed Jan 20 22:34:38 2010."
  end

  # status module must survive SERVICE_NOT_RUNNING
  def test_collectd_service_not_running
    response_graphs = fixture "service_not_running.xml"
    response_metrics = fixture "service_not_running.xml"
    response_logs = fixture "logs.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.logs" => "/logs",
          :"org.opensuse.yast.system.metrics" => "/metrics",
          :"org.opensuse.yast.system.graphs" => "/graphs",
          :"org.opensuse.yast.system.plugins" => "/plugins"},
          { :policy => "org.opensuse.yast.system.status" })
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 503
      mock.get   "/graphs.xml", @header, response_graphs, 503
      mock.get   "/plugins.xml", @header, @response_plugins, 200
      mock.get   "/metrics.xml", @header, response_metrics, 503
    end

    get :index
    assert_response :success
    assert_valid_markup
    assert_tag "Status not available."
  end

  #call for edit limits
  def test_edit
    get :edit
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
  end

  #writing limits
  def test_commit_limits
    put :save,  {"value/Memory/Memory/cached"=>"", "measurement/CPU/CPU-0/user"=>"max", "value/CPU/CPU-0/user"=>"", "value/CPU/CPU-1/user"=>"", "value/Network/eth0/received"=>"", "measurement/CPU/CPU-1/idle"=>"max", "measurement/CPU/CPU-0/idle"=>"max", "measurement/Network/eth0/sent"=>"max", "value/CPU/CPU-1/idle"=>"", "measurement/Network/eth0/received"=>"max", "measurement/Memory/Memory/free"=>"min", "measurement/Memory/Memory/used"=>"max", "value/Memory/Memory/used"=>"", "value/CPU/CPU-0/idle"=>"", "value/Network/eth0/sent"=>"", "value/Memory/Memory/free"=>"40", "measurement/Memory/Memory/cached"=>"max", "measurement/CPU/CPU-1/user"=>"max"}
    assert_response :redirect
    assert_redirected_to :controller => "status", :action => "index"
  end


end
