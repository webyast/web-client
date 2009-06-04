
module ViewHelpers::LabelHelper
    include GetText

    def label_add
	return _("Add")
    end

    def label_edit
	return _("Edit")
    end

    def label_delete
	return _("Delete")
    end
end
