class Author::CommitteeMembersController < AuthorController
  before_action :find_submission

  def new
    status_giver.can_provide_new_committee?
    @submission.build_committee_members_for_partners
    render :form
  rescue SubmissionStatusGiver::AccessForbidden => e
    redirect_to author_root_path
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator' unless e
    flash[:alert] = e if e
  end

  def create
    status_giver.can_provide_new_committee?
    @submission.save!(submission_params)
    status_giver.collecting_format_review_files!
    @submission.update! committee_provided_at: Time.zone.now
    flash[:notice] = 'Committee saved successfully'
    redirect_to author_root_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.values.join(" ")
    render :new
  rescue SubmissionStatusGiver::AccessForbidden
    flash.now[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def edit
    status_giver.can_update_committee?
    render :form
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def update
    @submission.update!(submission_params)
    status_giver.collecting_format_review_files! if @submission.status_behavior.collecting_committee?
    @submission.update! committee_provided_at: Time.zone.now
    flash[:notice] = 'Committee updated successfully'
    if params[:commit] == "Save and Continue Submission" || params[:commit] == 'Verify Committee'
      redirect_to author_root_path
    elsif params[:commit] == "Save and Input Program Head/Chair >>"
      redirect_to author_submission_head_of_program_path(@submission)
    elsif params[:commit] == "Update Program Head/Chair Information"
      redirect_to author_root_path
    else
      redirect_to edit_author_submission_committee_members_path(@submission)
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.values.join(" ")
    if params[:commit] == "Update Program Head/Chair Information"
      redirect_to author_submission_head_of_program_path(@submission)
    else
      render :form
    end
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  def show
    status_giver.can_create_or_edit_committee?
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You have not completed the required steps to review your committee yet'
    redirect_to author_root_path
  end

  def head_of_program
    status_giver.can_update_committee?
    @submission.committee_members.build(committee_role: @submission.degree_type.committee_roles.find_by(name: 'Program Head/Chair'), is_required: true) if CommitteeMember.head_of_program(@submission).blank?
    render :head_of_program_form
  rescue SubmissionStatusGiver::AccessForbidden
    flash[:alert] = 'You are not allowed to visit that page at this time, please contact your administrator'
    redirect_to author_root_path
  end

  private

    def status_giver
      SubmissionStatusGiver.new(@submission)
    end

    def find_submission
      @submission = current_author.submissions.find(params[:submission_id])
      @presenter = Author::CommitteeFormView.new(@submission)
    end

    def submission_params
      params.require(:submission).permit(committee_members_attributes: [:id, :name, :email, :committee_role_id, :is_required, :is_voting, :lion_path_degree_code, :_destroy])
    end
end
