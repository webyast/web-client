
module RepositoriesHelper
  def prio_mapping
    {
      0 => _("Highest"),
      50 => _("Higher"),
      99 => _("Default"),
      150 => _("Low"),
      200 => _("Lowest")
    }
  end

#  def prio_text priority
#    mapping = prio_mapping
#    return mapping[priority] if mapping.has_key? priority
#
#    _("Custom (%s)") % priority
#  end

  def prio_summary priority
    mapping = {
      0 => _("Highest priority"),
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
end