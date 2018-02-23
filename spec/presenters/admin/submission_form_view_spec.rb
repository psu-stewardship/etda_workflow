require 'presenters/presenters_spec_helper'
RSpec.describe Admin::SubmissionFormView do
  let(:view) { described_class.new(submission, session) }
  let(:submission) { FactoryBot.create :submission }
  let(:session) { {} }

  describe '#title' do
    context "When the status is before 'waiting for format review response'" do
      before { allow(submission.status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(false) }
      it "returns 'Edit Incomplete Format Review'" do
        expect(view.title).to eq 'Edit Incomplete Format Review'
      end
    end
    context "When the status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }
      it "returns 'Format Review Evaluation'" do
        expect(view.title).to eq 'Format Review Evaluation'
      end
    end
    context "When the status is 'collecting final submission files' and never rejected" do
      before do
        submission.status = 'collecting final submission files'
        allow(submission.status_behavior).to receive(:collecting_final_submission_files?).and_return(false)
      end
      it "returns 'Edit Completed Format Review'" do
        expect(view.title).to eq 'Edit Completed Format Review'
      end
    end

    context "When the final submission has been rejected" do
      before do
        submission.status = 'collecting final submission files'
        allow(submission.status_behavior).to receive(:collecting_final_submission_files_rejected?).and_return(true)
        submission.final_submission_rejected_at = Time.zone.yesterday
      end
      it "returns 'Edit Incomplete Final Submission'" do
        expect(view.title).to eq 'Edit Incomplete Final Submission'
      end
    end
    context "When the status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }
      it "returns 'Final Submission Evaluation'" do
        expect(view.title).to eq 'Final Submission Evaluation'
      end
    end
  end

  describe '#actions_partial_name' do
    context "When the status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }
      it "returns 'standard_actions'" do
        expect(view.actions_partial_name).to eq 'standard_actions'
      end
    end
    context "When the status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }
      it "returns 'standard_actions'" do
        expect(view.actions_partial_name).to eq 'standard_actions'
      end
    end
    context "When the status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }
      it "returns 'standard_actions'" do
        expect(view.actions_partial_name).to eq 'standard_actions'
      end
    end
    context "When the status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }
      it "returns 'format_review_evaluation_actions'" do
        expect(view.actions_partial_name).to eq 'format_review_evaluation_actions'
      end
    end
    context "When the status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }
      it "returns 'standard_actions'" do
        expect(view.actions_partial_name).to eq 'standard_actions'
      end
    end
    context "When the status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }
      it "returns 'final_submission_evaluation_actions'" do
        expect(view.actions_partial_name).to eq 'final_submission_evaluation_actions'
      end
    end
    context "When the status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }
      it "returns 'to_be_released_actions'" do
        expect(view.actions_partial_name).to eq 'to_be_released_actions'
      end
    end
    context "When the status is 'released for publication'" do
      before do
        submission.status = 'released for publication'
        submission.access_level = 'open_access'
      end
      it "returns 'released_actions'" do
        expect(view.actions_partial_name).to eq 'released_actions'
      end
    end
    context "When metadata is released and publication is restricted" do
      before do
        submission.status = 'released for publication'
        submission.access_level = 'restricted'
      end
      it "returns 'final_withheld'" do
        expect(view.actions_partial_name).to eq 'restricted_actions'
      end
    end
    context "When the status is 'psu-only'" do
      before do
        submission.status = 'released for publication'
        submission.access_level = 'restricted_to_institution'
      end
      it "returns 'final_restricted_institution'" do
        expect(view.actions_partial_name).to eq 'restricted_institution_actions'
      end
    end
  end
  describe '#form_for_url' do
    context "When the status is 'collecting program information'" do
      before { submission.status = 'collecting program information' }
      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end
    context "When the status is 'collecting committee'" do
      before { submission.status = 'collecting committee' }
      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end
    context "When the status is 'collecting format review files'" do
      before { submission.status = 'collecting format review files' }
      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end
    context "When the status is 'waiting for format review response'" do
      before { submission.status = 'waiting for format review response' }
      it "returns format review evaluation update path" do
        expect(view.form_for_url).to eq admin_submissions_format_review_response_path(submission)
      end
    end
    context "When the status is 'collecting final submission files'" do
      before { submission.status = 'collecting final submission files' }
      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end
    context "When the status is 'waiting for final submission response'" do
      before { submission.status = 'waiting for final submission response' }
      it "returns final submission evaluation update path" do
        expect(view.form_for_url).to eq admin_submissions_final_submission_response_path(submission)
      end
    end
    context "When the status is 'waiting for publication release'" do
      before { submission.status = 'waiting for publication release' }
      it "returns the waiting to be released update path" do
        expect(view.form_for_url).to eq admin_submissions_update_waiting_to_be_released_path(submission)
      end
    end
    context "When the status is 'released for publication'" do
      before { submission.status = 'released for publication' }
      it "returns the released for publication update path" do
        expect(view.form_for_url).to eq admin_submissions_update_released_path(submission)
      end
    end
  end

  describe '#cancellation_path' do
    context "When the status is before 'waiting for format review response'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/format_review_incomplete" } }

      before { allow(submission.status_behavior).to receive(:beyond_collecting_format_review_files?).and_return(false) }
      it "returns incomplete format review path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'format_review_incomplete')
      end
    end
    context "When the status is 'waiting for format review response'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/format_review_submitted" } }

      before { submission.status = 'waiting for format review response' }
      it "returns submitted format review path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'format_review_submitted')
      end
    end
    context "When the status is 'collecting final submission files'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/format_review_completed" } }

      before { submission.status = 'collecting final submission files' }
      it "returns incomplete final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'format_review_completed')
      end
    end
    context "When the status is 'waiting for final submission response'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_submitted" } }

      before { submission.status = 'waiting for final submission response' }
      it "returns submitted final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'final_submission_submitted')
      end
    end
    context "When the status is 'waiting for publication release'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_approved" } }

      before { submission.status = 'waiting for publication release' }
      it "returns approved final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'final_submission_approved')
      end
    end
    context "When the status is 'released for publication'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/released_for_publication" } }

      before { submission.status = 'released for publication' }
      it "returns released for publication path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type.slug, 'released_for_publication')
      end
    end
  end

  describe 'address' do
    let(:author) { FactoryBot.create :author }
    let(:submission) { FactoryBot.create :submission, author: author }

    context "the current author's address is returned" do
      it 'returns a full address' do
        expect(view.address).to eq('123 Example Ave.<br />Apt. 8H<br />State College, PA 16801')
      end
    end
    context 'it address is empty' do
      it 'returns an empty address' do
        author.address_1 = ''
        author.address_2 = ''
        author.city = ''
        author.zip = ''
        author.state = ''
        expect(view.address).to eq(' ')
      end
    end
  end

  describe 'committee_form for Lion Path' do
    let(:author) { FactoryBot.create :author }
    let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record, author: author }

    context 'the lion path committee_form is returned' do
      it 'returns the standard committee form when lion path is active' do
        if InboundLionPathRecord.active?
          # allow(InboundLionPathRecord).to receive(:active).and_return(true)
          expect(view.committee_form).to eq('lionpath_committee_form')
          expect(view.program_information_partial).to eq('lionpath_program_information')
        end
      end
    end
  end

  describe 'committee_form' do
    let(:author) { FactoryBot.create :author }
    let(:submission) { FactoryBot.create :submission, author: author }

    context 'the standard_committee_form is returned' do
      it 'returns the standard committee form when lion path is inactive' do
        author.inbound_lion_path_record = nil
        # allow(InboundLionPathRecord).to receive(:active).and_return(false)
        expect(view.committee_form).to eq('standard_committee_form')
        expect(view.program_information_partial).to eq('standard_program_information')
      end
    end
  end
  describe 'defense_date_partial_for_final_fields' do
    let(:author) { FactoryBot.create :author }
    let(:submission) { FactoryBot.create :submission, author: author }
    let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record, author: author }

    context 'the lion path defense date is used' do
      if InboundLionPathRecord.active?
        it 'uses the hidden defense date' do
          # allow(InboundLionPathRecord).to receive(:active).and_return(true)
          expect(view.defense_date_partial_for_final_fields).to eq('/admin/submissions/edit/defended_at_date_hidden') if current_partner.graduate?
        end
      end
    end
    context 'the date input by student is used' do
      it 'displays datepicker date' do
        author.inbound_lion_path_record = nil
        # allow(InboundLionPathRecord).to receive(:active).and_return(false)
        expect(view.defense_date_partial_for_final_fields).to eq('/admin/submissions/edit/standard_defended_at_date')
      end
    end
  end
  # describe 'psu_only' do
  #   let(:submission) { FactoryBot.create :submission, access_level: 'restricted_to_institution' }
  #
  #   context 'when access_level is restricted_to_institution' do
  #     it 'returns true' do
  #       x= view.psu_only(submission.current_access_level[:label])
  #       puts x.inspect
  #       expect(view.psu_only(submission.current_access_level[:label])).to be_truthy unless current_partner.graduate?
  #     end
  #   end
  #   context 'when access_level is not restricted_to_institution' do
  #     it 'returns true' do
  #       submission.access_level = 'Restricted'
  #       expect(view.psu_only(submission.current_access_level[:label])).to be_falsey
  #     end
  #   end
  # end
end
