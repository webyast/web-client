require "open3"

class ActionController::TestCase
  def assert_valid_markup(markup=@response.body)
    if @response.redirect?
      return
    end

    fail("Tidy is not available") unless system("which tidy &>/dev/null")

    Open3.popen3('tidy') do |stdin, stdout, stderr|
      # write the markup to tidy
      stdin.puts markup
      stdin.close_write
      stdout.read
      output = stderr.read

      messages = []
      output.each_line do |line|
        messages << line.chomp if line =~ /Warning|Info|Error/
      end

      errors = 0
      warns = 0
      if output =~ /^(\d+) warnings*, (\d+) errors*/
        warns = $1.to_i
        errors = $2.to_i
        assert (errors == 0 and warns == 0), "#{errors} validation errors and #{warns} warnings found:\n#{messages.map{ |x| "- #{x}"}.join("\n")}"
      end
      
    end
  end
end
