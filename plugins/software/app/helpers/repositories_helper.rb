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

module RepositoriesHelper
  def prio_mapping
    {
      1 => _("Highest"),
      50 => _("Higher"),
      99 => _("Default"),
      150 => _("Low"),
      200 => _("Lowest")
    }
  end

  def prio_summary priority
    mapping = {
      1 => _("Highest priority"),
      50 => _("Higher priority"),
      99 => '',
      150 => _("Low priority"),
      200 => _("Lowest priority")
    }

    return mapping[priority] if mapping.has_key? priority

    _("Custom priority")
  end

  def prio_selector form, priority, disabled
    mapping = prio_mapping
    mapping[priority] = _("Custom") unless mapping.has_key? priority

    select_content = []

    mapping.keys.sort.each { |key|
      select_content << [ mapping[key], key.to_s ]
    }

    form.select :priority, select_content, :selected => priority.to_s, :disabled => disabled
  end

  def bool_cmd val
    return val ? _('enable') : _('disable')
  end

  def bool_status val, opts = {:colors => {true => 'green', false => 'red'} }
    colors = opts[:colors] || {}
    ret = val ? _('enabled') : _('disabled')

    if colors[val]
      ret = "<span style='color: #{colors[val]}'>#{ret}</span>"
    end

    return ret
  end

  def hidden_field_with_link form, sid, flag, value, change

    html = <<-EOF
      <span id='repo_#{flag}_change_#{sid}' style='display: none'><b>#{change}</b></span>
      (<a onclick="switch_flag('#repo_#{flag}_link_#{sid}', '#repo_#{flag}_#{sid}', '#{value}', '#repo_#{flag}_change_#{sid}')"
	id="repo_#{flag}_link_#{sid}">#{bool_cmd !value}</a>)
    EOF

    return form.hidden_field(flag, :id => "repo_#{flag}_#{sid}", :value => value) + html

  end

  def hidden_field_with_toggle_link form, flag, value, enabled_text, disabled_text

    html = <<-EOF
      <span id='repo_#{flag}_enabled' #{value ? '' : "style='display: none'"}>#{enabled_text}</span>
      <span id='repo_#{flag}_disabled' #{value ? "style='display: none'" : ''}>#{disabled_text}</span>
      (<a onclick="toggle_flag('#repo_#{flag}_link', '#repo_#{flag}', '#repo_#{flag}_enabled', '#repo_#{flag}_disabled')"
	id="repo_#{flag}_link">#{bool_cmd !value}</a>)
    EOF

    return form.hidden_field(flag, :id => "repo_#{flag}", :value => value) + html
  end
end