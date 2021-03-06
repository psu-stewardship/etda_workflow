# frozen_string_literal: true

class CommitteeMember < ApplicationRecord
  class ProgramHeadMissing < StandardError; end

  validate :validate_email
  validate :one_head_of_program_check
  validates :committee_role_id,
            :name,
            :email, presence: true

  belongs_to :submission
  belongs_to :committee_role
  belongs_to :approver, optional: true
  has_one :committee_member_token, dependent: :destroy

  delegate :is_program_head, to: :committee_role

  STATUS = ["pending", "approved", "rejected"].freeze

  def self.advisors(submission)
    advisors_array = []
    submission.committee_members.each do |cm|
      advisors_array << cm if cm.committee_role.name.downcase.include? I18n.t("#{current_partner.id}.committee.special_role")
    end
    advisors_array
  end

  def self.advisor_name(submission)
    advisors_array = CommitteeMember.advisors(submission)
    return '' if advisors_array.empty?

    advisors_array.first.name
  end

  def self.remove_committee_members(submission)
    submission.committee_members.each(&:destroy)
    submission.save
  end

  def self.current_committee(submission_id)
    CommitteeMember.where(submission_id: submission_id).pluck(:committee_role_id, :is_required, :name, :email)
  end

  def self.program_head(submission)
    submission.committee_members.joins(:committee_role).find_by('committee_roles.is_program_head = 1')
  end

  def validate_email
    return true if email.blank?

    unless email.nil?
      return true if email.match?(/\A[\w]([^@\s,;]+)@(([\w-]+\.)+(.*))\z/i)
    end
    errors.add(:email, 'is invalid')
    false
  end

  def update_last_reminder_at(new_datetime)
    update_attribute(:last_reminder_at, new_datetime)
  end

  def reminder_email_authorized?
    return ((DateTime.now.to_time - last_reminder_at.to_time) / 60 / 60) > 24 if last_reminder_at

    true
  end

  def status=(new_status)
    return if new_status == self[:status]

    self[:status] = new_status
    case new_status
    when 'pending'
      self.approved_at = nil
      self.rejected_at = nil
    when 'approved'
      self.approved_at = Time.zone.now
      self.rejected_at = nil
    when 'rejected'
      self.rejected_at = Time.zone.now
      self.approved_at = nil
    end
  end

  def email=(new_email)
    return if new_email == self[:email]

    self[:email] = new_email.strip
    new_access_id = LdapUniversityDirectory.new.retrieve_committee_access_id(self[:email])
    self.access_id = new_access_id
    return unless committee_member_token.blank? && access_id.blank?

    token = CommitteeMemberToken.new authentication_token: SecureRandom.urlsafe_base64(nil, false)
    self.committee_member_token = token
    committee_member_token.save!
  end

  def committee_role_id=(new_committee_role_id)
    return if new_committee_role_id.blank? || (new_committee_role_id == self[:committee_role_id])

    self[:committee_role_id] = new_committee_role_id

    self[:is_voting] = true unless CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' ||
                                   CommitteeRole.find(new_committee_role_id).is_program_head
    self[:is_voting] = false if CommitteeRole.find(new_committee_role_id).name == 'Special Signatory' ||
                                CommitteeRole.find(new_committee_role_id).is_program_head
  end

  def name=(new_name)
    super(new_name.strip)
  end

  private

  def one_head_of_program_check
    return true unless committee_role.present? && submission.present? && is_program_head

    program_head = CommitteeMember.program_head(submission)
    head_committee_member_id = (program_head ? program_head.id : nil)
    return true if (head_committee_member_id.nil? || head_committee_member_id == self[:id]) &&
                   (submission.committee_members.collect { |n| n.committee_role.present? ? n.is_program_head : nil }
                   .count(true) < 2)

    errors.add(:committee_role_id, 'A submission may only have one Program Head/Chair.')
    false
  end
end
