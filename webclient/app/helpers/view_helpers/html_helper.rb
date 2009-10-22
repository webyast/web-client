
module ViewHelpers::HtmlHelper

    def html_edit_link(id, action = :edit)
	return link_to image_tag("/images/edit-icon.gif", :alt => :edit), {:action => action, :id => id}, :onclick=>"Element.show('progress')"
    end

    def html_delete_link(id, action = :delete)
	return link_to image_tag("/images/delete.png", :alt => :delete), {:action => action, :id => id},
	:confirm => _('Are you sure?'), :method => :delete
    end

    def html_create_table_content(items, properties, permissions = {}, proc_obj = nil)
	ret = ''
	columns = properties.size

	items.each do |item|
	    line = ''
	    columns.times { |col|
		property = properties[col]

		if !property.nil? && item.respond_to?(property)
		    cell = item.send(property)
		else
		    if proc_obj.nil?
			cell = "ERROR: unknown method #{property}"
		    else
			cell = proc_obj.call(item, col)
		    end
		end

		line += "<td>#{h(cell)}</td>"
	    }

	    if permissions[:edit]
		line += "<td align=\"center\">#{html_edit_link(item.send(permissions[:id]))}</td>"
	    end

	    if permissions[:delete]
		line += "<td align=\"center\">#{html_delete_link(item.send(permissions[:id]))}</td>"
	    end

	    ret += "<tr>#{line}</tr>"
	end

	return ret
    end

    ##
    # Create a simple HTML table
    #
    # Parameters:
    # * labels - an array of strings - table headings
    # * items - an array of objects - table content
    # * properties - an array of strings - name of the method which will be called for the respective column.
    #   The result will be displayed in the table.
    # * permissions - a hash with permissions - used to display/hide Add, Edit, and Delete buttons.
    #   The argument is optional, if missing no button will be displayed. Expected keys are :add, :edit, :delete.
    #   If a key is missing or the value is false the relevant button is hidden.
    # * optional block with two arguments: object and column number - this block is used
    #   for computing table values for columns with property method set to nil. See the example.
    #   Use the column block parameter to distinguish the columns if there are several columns with nil property.
    #
    # Examples:
    #
    # <tt>simple_table([_("First Name"), _("Surname")], @users, [:first_name, :surname], {:add => true, :edit => true, :delete => true, :id => :name})</tt>
    #
    # <tt>simple_table([_("Avg. Download Speed")], files, [nil]){|file, column| "#{file.size/file.download_time/1024} kB/s"}</tt>
    #
    def html_simple_table(labels, items, properties, permissions = {}, &block)
	header = ''

	labels.each { |l|
	    header += "<th class=\"first\">#{h(l)}</th>"
	}

	if permissions[:edit]
	    header += "<th class=\"first\" width=10%>#{h(label_edit)}</th>"
	end

	if permissions[:delete]
	    header += "<th class=\"first\" width=10%>#{h(label_delete)}</th>"
	end

	content = html_create_table_content(items, properties, permissions, block)

	ret = "<table class=\"list\"><tr>#{header}</tr>#{content}</table>"

	ret += "<br>" + button_to(label_add, {:action => "new"}) if permissions[:add]

	return ret
    end

    # clipboard icon for a predefined text
    def clippy(text, bgcolor='#FFFFFF')
  html = <<-EOF
    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
            width="110"
            height="14"
            id="clippy" >
    <param name="movie" value="/flash/clippy.swf"/>
    <param name="allowScriptAccess" value="always" />
    <param name="quality" value="high" />
    <param name="scale" value="noscale" />
    <param NAME="FlashVars" value="text=#{text}">
    <param name="bgcolor" value="#{bgcolor}">
    <embed src="/flash/clippy.swf"
           width="110"
           height="14"
           name="clippy"
           quality="high"
           allowScriptAccess="always"
           type="application/x-shockwave-flash"
           pluginspage="http://www.macromedia.com/go/getflashplayer"
           FlashVars="text=#{text}"
           bgcolor="#{bgcolor}"
    />
    </object>
  EOF
  end

  # report an exception to the flash messages zone
  # a flash error message will be appended to the
  # element with id "flashes" with standard jquery
  # ui styles. A link with more information that
  # display a popup is also automatically created    
  def report_error(error, message=nil)
    # get the id of the error, or use a random id
    error_id = error.nil? ? rand(10000) : error.object_id
    # get the backtrace, or create a message saying there is none
    backtrace_text = _("No information available")
    if error.kind_of? ActiveResource::ConnectionError
      backtrace_text =  error.response.body
    else
      backtrace_text = error.backtrace.join("\n") unless (error.nil? || error.backtrace.nil? || error.backtrace.blank?)

    # the summary message
    if message.nil?
      message = "There was a problem retrieving information from the server."
    end

    # build the html    
    html =<<-EOF2
      <div id="error-#{error_id}-content">
        <div>
          <p><strong>Error message:</strong>#{error.message}</p>
          <p><a href="#{@bug_url}">Report bug</a></p>
          <p><a href="#" id="error-#{error_id}-show-backtrace-link">Show details</a>#{clippy(backtrace_text)}</p></p>
          <pre id="error-#{error_id}-backtrace" style="display: none">
          #{backtrace_text}
          </pre>
        </div>
      </div>

      <div class="ui-state-error ui-corner-all" style="margin-top: 20px; padding: 0 .7em;" id="error-#{error_id}-summary">
        <p><span class="ui-icon ui-icon-alert"/>#{message} (<a href="#" id="error-#{error_id}-details-link">more..</a>)</p>
      </div>

      <script type="text/javascript">
        $(document).ready(
          function() {
            //$('#error-#{error_id}-summary').hide();

            // hide the exception details
            $('#error-#{error_id}-content').hide();

            // put the error summary with the other flashes
            // and not where the output should go
            $('#flash-messages').prepend($('#error-#{error_id}-summary'));

            //$('#error-#{error_id}-content').show();
    
           // define a dialog with the error details
           $('#error-#{error_id}-content').dialog(
           {
    	     bgiframe: true,
    	     autoOpen: false,
    	     height: 300,
    	     modal: true
           });

           // make the More link to open the dialog with details
           $('#error-#{error_id}-details-link').click( function() {
             $('#error-#{error_id}-content').dialog('open');
           });

           // make the Show details links show the backtrace
           $('#error-#{error_id}-show-backtrace-link').click(function() {
             $('#error-#{error_id}-backtrace').hide();
             $('#error-#{error_id}-backtrace').show();
             return false;
           });
         });
     </script>
EOF2
  end
  
end

# vim: ft=ruby
