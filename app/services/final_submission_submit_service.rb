class FinalSubmissionSubmitService
  attr_accessor :submission, :status_giver, :approval_status, :final_submission_params

  def initialize(submission, status_giver, approval_status, final_submission_params)
    @submission = submission
    @status_giver = status_giver
    @approval_status = approval_status
    @final_submission_params = final_submission_params
  end

  def submit_final_submission
    status_giver.can_upload_final_submission_files?
    submission.update!(final_submission_params)
    submission.update_attribute :publication_release_terms_agreed_to_at, Time.zone.now
    if submission.status == 'waiting for committee review rejected'
      committee_reject_submit
      return
    elsif submission.status == 'collecting final submission files rejected' && current_partner.honors?
      final_sub_reject_submit
      return
    end
    collect_final_sub_submit
  end

  private

  def committee_reject_submit
    current_partner.honors? ? status_giver.can_waiting_for_committee_review? : status_giver.can_waiting_for_final_submission?
    current_partner.honors? ? status_giver.waiting_for_committee_review! : status_giver.waiting_for_final_submission_response!
    OutboundLionPathRecord.new(submission: submission).report_status_change
    submission.reset_committee_reviews
    submission.update_final_submission_timestamps!(Time.zone.now)
    WorkflowMailer.send_final_submission_received_email(submission)
  end

  def final_sub_reject_submit
    status_giver.can_waiting_for_committee_review?
    status_giver.waiting_for_committee_review!
    submission.reset_committee_reviews unless approval_status == 'approved'
    submission.update_status_from_committee
    OutboundLionPathRecord.new(submission: submission).report_status_change
    submission.update_final_submission_timestamps!(Time.zone.now)
    WorkflowMailer.send_final_submission_received_email(submission)
    submission.committee_review_requests_init unless approval_status == 'approved'
  end

  def collect_final_sub_submit
    if current_partner.honors?
      collect_final_honors
    else
      collect_final_other
    end
    OutboundLionPathRecord.new(submission: submission).report_status_change
    submission.update_final_submission_timestamps!(Time.zone.now)
    WorkflowMailer.send_final_submission_received_email(submission)
  end

  def collect_final_honors
    status_giver.can_waiting_for_committee_review?
    status_giver.waiting_for_committee_review!
    submission.reset_committee_reviews
    submission.committee_review_requests_init unless approval_status == 'approved'
  end

  def collect_final_other
    status_giver.can_waiting_for_final_submission?
    status_giver.waiting_for_final_submission_response!
  end
end
