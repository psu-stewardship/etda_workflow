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

    context "When the status is 'waiting in final submission hold'" do
      before { submission.status = 'waiting in final submission on hold' }

      it "returns 'on_hold_actions'" do
        expect(view.actions_partial_name).to eq 'on_hold_actions'
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

    context "When the status is 'waiting in final submission on hold'" do
      before { submission.status = 'waiting in final submission hold' }

      it "returns the waiting to be released update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end

    context "When the status is 'released for publication'" do
      before { submission.status = 'released for publication' }

      it "returns the released for publication update path" do
        expect(view.form_for_url).to eq admin_submissions_update_released_path(submission)
      end
    end

    context "When the status is 'waiting for committee review'" do
      before { submission.status = 'waiting for committee review' }

      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
      end
    end

    context "When the status is 'waiting for committee review rejected'" do
      before { submission.status = 'waiting for committee review rejected' }

      it "returns the normal update path" do
        expect(view.form_for_url).to eq admin_submission_path(submission)
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

    context "When the status is 'waiting for committee review'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_pending" } }

      before { submission.status = 'waiting for committee review' }

      it "returns submitted final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'final_submission_pending')
      end
    end

    context "When the status is 'waiting for committee review rejected'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/committee_review_rejected" } }

      before { submission.status = 'waiting for committee review rejected' }

      it "returns submitted final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'committee_review_rejected')
      end
    end

    context "When the status is 'waiting for publication release'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_approved" } }

      before { submission.status = 'waiting for publication release' }

      it "returns approved final submission path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'final_submission_approved')
      end
    end

    context "When the status is 'waiting in final submission on hold'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_hold" } }

      before { submission.status = 'waiting in final submission on hold' }

      it "returns final submission hold path" do
        expect(view.cancellation_path).to eq admin_submissions_index_path(submission.degree_type, 'final_submission_on_hold')
      end
    end

    context "When the status is 'released for publication'" do
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/released_for_publication" } }

      before { submission.status = 'released for publication' }

      it "returns released for publication path" do
        expect(view.cancellation_path).to eq admin_submissions_dashboard_path(submission.degree_type.slug)
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

    context 'the lion path committee_form is returned' do
      it 'returns the standard committee form when lion path is active' do
        allow_any_instance_of(Submission).to receive(:using_lionpath?).and_return(true)
        inbound_lion_path_record = InboundLionPathRecord.new(author_id: author.id, lion_path_degree_code: LionPath::MockLionPathRecord.first_degree_code, current_data: LionPath::MockLionPathRecord.current_data)
        author.inbound_lion_path_record = inbound_lion_path_record
        expect(view.committee_form).to eq('lionpath_committee_form')
        expect(view.program_information_partial).to eq('lionpath_program_information')
      end
    end
  end

  describe 'committee_form' do
    let(:author) { FactoryBot.create :author }
    let(:submission) { FactoryBot.create :submission, author: author }

    context 'the standard_committee_form is returned' do
      it 'returns the standard committee form when lion path is inactive' do
        author.inbound_lion_path_record = nil
        allow(InboundLionPathRecord).to receive(:active?).and_return(false)
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
  #   context 'when access_level is restricted_to_institution for graduate submissions' do
  #     it 'returns true' do
  #       expect(view.psu_only(submission.current_access_level.attributes)).to eql('Restricted (Penn State Only)')
  #     end
  #   end
  #   context 'when access_level is not restricted_to_institution' do
  #     it 'returns true' do
  #       submission.access_level = 'Restricted'
  #       expect(view.psu_only(submission.current_access_level.attributes)).to be_falsey
  #     end
  #   end
  # end

  describe 'release_date_history' do
    it 'displays partial release date and expected full release date for restricted submissions' do
      submission = FactoryBot.create :submission, :final_is_restricted
      view = described_class.new(submission, session)
      expect(view.release_date_history).to eq("<b>Metadata released:</b> #{formatted_date(submission.released_metadata_at)}<br /><b>Scheduled for full release: </b> #{formatted_date(submission.released_for_publication_at)}")
    end
    it 'displays partial release date and expected full release date for restricted-to-institution submissions' do
      submission = FactoryBot.create :submission, :final_is_restricted_to_institution
      view = described_class.new(submission, session)
      expect(view.release_date_history).to eq("<b>Released to Penn State Community: </b> #{formatted_date(submission.released_metadata_at)}<br /><b>Scheduled for full release: </b>#{formatted_date(submission.released_for_publication_at)}")
    end
    it 'displays the release date for open submissions' do
      submission = FactoryBot.create :submission, :released_for_publication
      view = described_class.new(submission, session)
      expect(view.release_date_history).to eq("<b>Released for publication: </b>#{formatted_date(submission.released_for_publication_at)}")
      submission.released_metadata_at = Date.yesterday
      expect(view.release_date_history).to eq("<b>Metadata released:</b> #{formatted_date(submission.released_metadata_at)}<br /><b>Released for publication: </b>#{formatted_date(submission.released_for_publication_at)}")
    end
  end

  describe 'collapsed content' do
    context 'when admin reviews a submitted format review file' do
      it 'displays format-review-files section' do
        submission = FactoryBot.create :submission, status: 'waiting for format review response'
        view = described_class.new(submission, session)
        expect(view.form_section_heading('format-review-files')).to eql("class='form-section-heading collapse in'")
        expect(view.form_section_body('format-review-files')).to eql("class='form-section-body collapse in'")
      end
      it 'does not display committee information' do
        submission = FactoryBot.create :submission, status: 'waiting for format review response'
        view = described_class.new(submission, session)
        expect(view.form_section_heading('committee')).to eql("class='form-section-heading collapsed' aria-expanded='false'")
        expect(view.form_section_body('committee')).to eql("class='form-section-body collapse' aria-expanded='false'")
      end
    end

    context 'when admin reviews a submitted final submission file' do
      it 'displays format-review-files section' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response'
        view = described_class.new(submission, session)
        expect(view.form_section_heading('final-submission-files')).to eql("class='form-section-heading collapse in'")
        expect(view.form_section_body('final-submission-files')).to eql("class='form-section-body collapse in'")
      end
      it 'does not display committee information' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response'
        view = described_class.new(submission, session)
        expect(view.form_section_heading('format-review-files')).to eql("class='form-section-heading collapsed' aria-expanded='false'")
        expect(view.form_section_body('format-review-files')).to eql("class='form-section-body collapse' aria-expanded='false'")
        expect(view.form_section_heading('committee')).to eql("class='form-section-heading collapsed' aria-expanded='false'")
        expect(view.form_section_body('committee')).to eql("class='form-section-body collapse' aria-expanded='false'")
      end
    end
  end

  describe '#button_message' do
    let!(:degree) { FactoryBot.create :degree }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type }

    context 'when committee has not approved or rejected' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('none')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('none')
      end

      it 'returns the next workflow step' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.button_message).to eq 'Final Submission is Pending'
      end
    end

    context 'when committee has approved' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('approved')
      end

      it 'returns the next workflow step' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.button_message).to eq 'Final Submission to be Released'
      end
    end

    context 'when committee has rejected' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('rejected')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('rejected')
      end

      it 'returns the next workflow step' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.button_message).to eq 'Committee Review Rejected'
      end
    end
  end

  describe '#confirmation_message' do
    let!(:degree) { FactoryBot.create :degree }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type }

    context 'when committee has not approved or rejected' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('none')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('none')
      end

      it 'returns a message' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.confirmation_message).to eq "Are you sure you would like to approve this submission?  This will initiate the committee review stage, which will send emails out to members of the committee."
      end
    end

    context 'when committee has approved' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('approved')
      end

      it 'returns a message' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.confirmation_message).to eq "The committee for this submission has already approved.  Move this submission to 'Final Submission to be Released' and skip the committee review?"
      end
    end

    context 'when committee has rejected' do
      before do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('rejected')
        allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('rejected')
      end

      it 'returns a message' do
        submission = FactoryBot.create :submission, status: 'waiting for final submission response', degree: degree
        view = described_class.new(submission, session)
        expect(view.confirmation_message).to eq "The committee for this submission has already rejected.  Move this submission to 'Committee Review Rejected' and skip the committee review?"
      end
    end
  end
end
