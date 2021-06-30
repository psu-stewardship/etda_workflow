class Author::FinalSubmissionFilesView
  def initialize(submission_record)
    @record = submission_record || nil
  end

  def author_access_level_view
    return 'access_level_static' if current_partner.milsch?

    'access_level_standard'
  end

  def disclosure_class
    return '' if current_partner.milsch?
    return '' if @record.access_level.restricted?

    'd-none'
  end

  def selected_access_level
    return AccessLevel.OPEN_ACCESS.attributes if @record.access_level.empty?

    @record.current_access_level.label
  end

  def psu_only(label)
    label == AccessLevel.RESTRICTED_TO_INSTITUTION.attributes
  end
end
