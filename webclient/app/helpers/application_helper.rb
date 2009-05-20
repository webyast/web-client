# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def add
	return _("Add")
    end

    def edit
	return _("Edit")
    end

    def delete
	return _("Delete")
    end

    def edit_link(id, action = :edit)
	return link_to image_tag("/images/edit-icon.gif", :alt => :edit), {:action => action, :id => id}, :onclick=>"Element.show('progress')"
    end

    def delete_link(id, action = :delete)
	return link_to image_tag("/images/delete.png", :alt => :delete), {:action => action, :id => id},
	:confirm => _('Are you sure?'), :method => :delete
    end

    def create_table_content(items, properties = [], permissions = {}, proc_obj = nil)
	ret = ''
	columns = properties.size

	items.each do |item|
	    line = ''
	    columns.times { |col|
		property = properties[col]


		if !property.blank? && item.respond_to?(property)
		    cell = item.send(property)
		else
		    if proc_obj.nil?
			cell = "ERROR: unknown method #{property}"
		    else
		debugger
			cell = proc_obj.call(item, col)
		    end
		end

		line += "<td>#{h(cell)}</td>"
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

    def simple_table(labels, items, properties = [], permissions = {}, &block)
	header = ''

	labels.each { |l|
	    header += "<th class=\"first\">#{h(l)}</th>"
	}

	if permissions[:edit]
	    header += "<th class=\"first\" width=10%>#{h(edit)}</th>"
	end

	if permissions[:delete]
	    header += "<th class=\"first\" width=10%>#{h(delete)}</th>"
	end

	content = create_table_content(items, properties, permissions, block)

	ret = "<table class=\"list\"><tr>#{header}</tr>#{content}</table>"

	ret += "<br>" + button_to(add, {:action => "new"}) if permissions[:add]

	return ret
    end

end

# vim: ft=ruby
