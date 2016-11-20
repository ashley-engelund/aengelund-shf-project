module MembershipApplicationHelper

  def edit_status?
    policy(@membership_application).permitted_attributes_for_edit.include? :status
  end

  def uploaded_file_inline(upload_file)
    "#{upload_file.actual_file_file_name} #{label_unless_blank('title', upload_file.title)} #{label_unless_blank('description', upload_file.description)}"
  end

  def label_unless_blank(label, value)
    value.blank? ? '' : "#{label}: #{value}"
  end
end
