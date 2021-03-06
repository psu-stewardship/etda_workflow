require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionSubmitService do
  let!(:submission) { FactoryBot.create :submission, degree: degree }
  let!(:status_giver) { SubmissionStatusGiver.new(submission) }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }

  let!(:approval_configuration) do
    FactoryBot.create(:approval_configuration, head_of_program_is_approving: false, degree_type: degree.degree_type)
  end

  before do
    create_committee(submission)
  end

  context 'when submission is submitted after admin rejection' do
    it 'proceeds to the "waiting for final submission response" stage' do
      submission.update status: 'collecting final submission files rejected'
      service = described_class.new(submission, status_giver, {})
      service.submit_final_submission
      expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
      expect(WorkflowMailer.deliveries.count).to eq 1
    end
  end

  describe "#submit_final_submission" do
    context "when author submits final submission for the first time" do
      it "proceeds submission to next step in workflow" do
        submission.status = 'collecting final submission files'
        final_submission_params = {}
        described_class.new(submission, status_giver, final_submission_params).submit_final_submission
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
      end
    end

    context "when author submits final submission after committee rejects" do
      it "proceeds submission to next step in workflow and resets committee statuses" do
        submission.status = 'waiting for committee review rejected'
        committee_member = FactoryBot.create :committee_member, status: 'Rejected'
        submission.committee_members << committee_member
        final_submission_params = {}
        described_class.new(submission, status_giver, final_submission_params).submit_final_submission
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
        expect(CommitteeMember.find(committee_member.id).status).to eq ''
      end
    end
  end
end
