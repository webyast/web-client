

module HTML

    def HTML.edit_link(id, action = :edit)
	return link_to image_tag("/images/edit-icon.gif", :alt => :edit), {:action => action, :id => id}, :onclick=>"Element.show('progress')"
    end

    def HTML.delete_link(id, action = :delete)
	return link_to image_tag("/images/delete.png", :alt => :delete), {:action => action, :id => id},
	:confirm => _('Are you sure?'), :method => :delete
    end

    def HTML.create_table_content(items, properties, permissions = {}, proc_obj = nil)
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

		line += "<td>#{ERB::Util::html_escape(cell)}</td>"
	    }

	    if permissions[:edit]
		line += "<td align=\"center\">#{edit_link(item.send(permissions[:id]))}</td>"
	    end

	    if permissions[:delete]
		line += "<td align=\"center\">#{delete_link(item.send(permissions[:id]))}</td>"
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
    def HTML.simple_table(labels, items, properties, permissions = {}, &block)
	header = ''

	labels.each { |l|
	    header += "<th class=\"first\">#{ERB::Util::html_escape(l)}</th>"
	}

	if permissions[:edit]
	    header += "<th class=\"first\" width=10%>#{ERB::Util::html_escape(Label.edit)}</th>"
	end

	if permissions[:delete]
	    header += "<th class=\"first\" width=10%>#{ERB::Util::html_escape(Label.delete)}</th>"
	end

	content = create_table_content(items, properties, permissions, block)

	ret = "<table class=\"list\"><tr>#{header}</tr>#{content}</table>"

	ret += "<br>" + button_to(add, {:action => "new"}) if permissions[:add]

	return ret
    end

end

