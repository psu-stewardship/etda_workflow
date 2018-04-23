class Admin::SubmissionsIndexView
  attr_reader :submissions
  attr_reader :degree_type, :scope

  def initialize(degree_type, scope, context)
    @degree_type = DegreeType.find_by!(slug: degree_type)
    @scope = scope
    @submissions = Submission.joins(:degree).includes(:author).where('degrees.degree_type_id' => @degree_type.id).send(scope_method).map { |s| Admin::SubmissionView.new(s, context) }
  end

  def submission_views
    submissions
  end

  def table_header_partial_path
    "admin/submissions/table_headers/#{@scope}"
  end

  def table_body_partial_path
    "admin/submissions/table_bodies/#{@scope}"
  end

  def title
    I18n.t("#{translation_key}.title")
  end

  def id
    return 'incomplete-format-review-submissions-index' if format_review_incomplete?
    return 'submitted-format-review-submissions-index' if format_review_submitted?
    return 'completed-format-review-submissions-index' if format_review_completed?
    return 'incomplete-final-submission-submissions-index' if final_submission_incomplete?
    return 'submitted-final-submission-submissions-index' if final_submission_submitted?
    return 'approved-final-submission-submissions-index' if final_submission_approved?
    return 'final-restricted-institution-index' if final_restricted_institution?
    return 'final-withheld-index' if final_withheld?
    'released-for-publication-submissions-index'
  end

  def render_additional_bulk_actions?
    !additional_bulk_actions_path.nil?
  end

  def additional_bulk_actions_path
    if final_submission_approved?
      'admin/submissions/table_bulk_actions/final_submission_approved'
    elsif final_restricted_institution? || final_withheld?
      'admin/submissions/table_bulk_actions/final_submission_restricted_or_witheld'
    end
  end

  def render_additional_selections?
    additional_selections_path.present?
  end

  def additional_selections_path
    return unless final_restricted_institution? || final_withheld?
    'admin/submissions/table_selections/final_submission_restricted_or_witheld'
  end

  def render_export_final_submission_button?
    final_submission_approved?
  end

  def delete_button_partial
    'admin/submissions/table_bulk_actions/delete_button'
  end

  def render_delete_button?
    return true unless final_restricted_institution? || final_withheld? || released_for_publication?
    false
  end

  def select_visible_buttons_partial
    'admin/submissions/table_bulk_actions/select_visible_buttons'
  end

  def render_select_visible_buttons?
    return true unless released_for_publication?
    false
  end

  def current_semester
    @current_semester ||= Semester.current
  end

  private

    def format_review_incomplete?
      @scope == 'format_review_incomplete'
    end

    def format_review_submitted?
      @scope == 'format_review_submitted'
    end

    def format_review_completed?
      @scope == 'format_review_completed'
    end

    def final_submission_incomplete?
      @scope == 'final_submission_incomplete'
    end

    def final_submission_submitted?
      @scope == 'final_submission_submitted'
    end

    def final_submission_approved?
      @scope == 'final_submission_approved'
    end

    def released_for_publication?
      @scope == 'released_for_publication'
    end

    def final_restricted_institution?
      @scope == 'final_restricted_institution'
    end

    def final_withheld?
      @scope == 'final_withheld'
    end

    def scope_method
      return 'format_review_is_incomplete' if format_review_incomplete?
      return 'format_review_is_submitted' if format_review_submitted?
      return 'format_review_is_completed' if format_review_completed?
      return 'final_submission_is_incomplete' if final_submission_incomplete?
      return 'final_submission_is_submitted' if final_submission_submitted?
      return 'final_submission_is_approved' if final_submission_approved?
      return 'final_is_restricted_institution' if final_restricted_institution?
      return 'final_is_withheld' if final_withheld?
      'released_for_publication'
    end

    def translation_key
      "#{current_partner.id}.admin_filters.#{scope}"
    end
end
