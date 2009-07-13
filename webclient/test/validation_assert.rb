
class ActionController::TestCase
  def assert_valid_markup(markup=@response.body)
    if @response.redirect?
      return
    end

    fail("Tidy is not available") unless system("which tidy &>/dev/null")

    validate_temp = File.new("#{RAILS_ROOT}/tmp/validate.html", 'w')
    validate_temp.puts markup
    validate_temp.close

    system("tidy #{RAILS_ROOT}/tmp/validate.html 1>/dev/null 2>#{RAILS_ROOT}/tmp/validate.result")
    result = `grep '^[0-9]\\+ warnings*, [0-9]\\+ errors*' #{RAILS_ROOT}/tmp/validate.result`    
    assert result.empty?, "Find validation problems: "+`cat #{RAILS_ROOT}/tmp/validate.result`
  end
end
