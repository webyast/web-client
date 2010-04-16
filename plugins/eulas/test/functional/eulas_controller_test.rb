require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class EulasControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    @eulas_response = fixture "eulas.xml"
    @eulas_accepted_response = fixture "eulas_accepted.xml"
    @sles_eula_response = fixture "sles_eula.xml"
    @sles_eula_accepted_response = fixture "sles_eula_accepted.xml"
    @sles_eula_de_response = fixture "sles_eula_de.xml"

    EulasController.any_instance.stubs(:login_required)
    @controller = EulasController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.eulas" => "/eulas"
      mock.permissions "org.opensuse.yast.modules.eulas", { :read => true, :write => true }
      mock.get  "/eulas.xml", header, @eulas_response, 200
      mock.get  "/eulas/1.xml", header, @sles_eula_response, 200
      mock.get  "/eulas/1.xml?lang=de", header, @sles_eula_de_response, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_eula_start
    session[:eula_count] = nil
    get :index
    assert_redirected_to "/eulas/show/1"
    assert_not_nil session[:eula_count]
  end

  def test_eula_step
    get :index
    assert_redirected_to "/eulas/show/1"
    get :show, :id => 1, "eula_lang" => "de"
    assert_response :success
    post :update, :eula => {"accepted" => "false"}, "id" => "1"
    assert_redirected_to "/eulas/show/1"
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.eulas" => "/eulas"
      mock.permissions "org.opensuse.yast.modules.eulas", { :read => true, :write => true }
      mock.get  "/eulas.xml", header, @eulas_accepted_response, 200
      mock.get  "/eulas/1.xml", header, @sles_eula_response, 200
      mock.put  "/eulas/1.xml", header, @sles_eula_accepted_response, 200
    end
    post :update, :eula => {"accepted" => "true"}, "id" => "1"
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  def test_eula_step_in_wizard
    Basesystem.stubs(:installed?).returns(true)
    session[:wizard_current] = "test"
    session[:wizard_steps] = "systemtime,eulas,language"
    get :index
    post :update, :eula => {"accepted" => "false"}, "id" => "1"
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.eulas" => "/eulas"
      mock.permissions "org.opensuse.yast.modules.eulas", { :read => true, :write => false }
      mock.get  "/eulas.xml", header, @eulas_accepted_response, 200
      mock.get  "/eulas/1.xml", header, @sles_eula_response, 200
      mock.put  "/eulas/1.xml", header, @sles_eula_accepted_response, 200
    end
    post :update, :eula => {"accepted" => "true"}, "id" => "1"
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end
end
