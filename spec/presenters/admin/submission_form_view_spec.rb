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

    context "When the status is 'waiting in final submission on hold'" do
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
      before { submission.status = 'waiting in final submission on hold' }

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

    context "When the status is 'waiting for committee review'" do
      before { submission.status = 'waiting for committee review' }

      it "returns final submission pending response" do
        expect(view.form_for_url).to eq admin_submissions_final_submission_pending_response_path(submission)
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
      let(:session) { { return_to: "/admin/#{submission.degree_type.slug}/final_submission_on_hold" } }

      before { submission.status = 'waiting in final submission on hold' }

      it "returns final submission on hold path" do
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
        expect(view.form_section_heading('format-review-files')).to eql("class='form-section-heading collapse show'")
        expect(view.form_section_body('format-review-files')).to eql("class='form-section-body collapse show'")
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
        expect(view.form_section_heading('final-submission-files')).to eql("class='form-section-heading collapse show'")
        expect(view.form_section_body('final-submission-files')).to eql("class='form-section-body collapse show'")
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
end
