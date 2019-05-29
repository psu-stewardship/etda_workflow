# frozen_string_literal: true

class ApprovalStatus
  attr_reader :current_submission, :voting_committee_members, :approval_configuration

  WORKFLOW_STATUS =
    [
      'none',
      'pending',
      'approved',
      'rejected'
    ].freeze

  def initialize(submission)
    @current_submission = submission
    @voting_committee_members = submission.voting_committee_members
    @approval_configuration = submission.degree.degree_type.approval_configuration
  end

  def status
    none || approved || rejected || pending
  end

  private

  def none
    return 'none' if voting_committee_members.count.zero?
  end

  def approved
    return 'approved' unless (voting_committee_members.collect { |m| m.status == 'approved' }).count(false) > rejections_permitted
  end

  def rejected
    return 'rejected' if (voting_committee_members.collect { |m| m.status == 'rejected' }).count(true) > rejections_permitted
  end

  def pending
    'pending'
  end

  def rejections_permitted
    if approval_configuration.use_percentage == false
      approval_configuration.rejections_permitted
    else
      voting_committee_members.count - (voting_committee_members.count.to_f * ((approval_configuration.percentage_for_approval.to_f) / 100)).round
    end
  end
end
