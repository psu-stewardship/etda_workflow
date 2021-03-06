RSpec.describe 'Step 5: Collecting Final Submission Files', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting final submission files'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, lion_path_degree_code: 'PHD', author: author, degree: degree }
    let!(:committee_members) { create_committee(submission) }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

    context "visiting the 'Update Program Information' page" do
      it 'raises a forbidden access error' do
        visit edit_author_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Provide Committee' page" do
      it 'raises a forbidden access error' do
        visit new_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Committee' page" do
      it 'raises a forbidden access error' do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Upload Format Review Files' page" do
      it 'raises a forbidden access error' do
        visit author_submission_edit_format_review_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'displays the program information page' do
        visit author_submission_program_information_path(submission)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
        expect(page).to have_content(submission.title)
      end
    end

    context "visiting the 'Review Committee' page" do
      it 'displays the committee information page' do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_content(submission.committee_members.first.name)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it 'displays the review format review files page' do
        visit author_submission_format_review_path(submission)
        expect(page).to have_content(submission.title)
        expect(page).to have_current_path(author_submission_format_review_path(submission))
      end
    end

    context "visiting the 'Upload Final Submission Files page'" do
      it 'displays the upload final submission files page' do
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_current_path(author_submission_edit_final_submission_path(submission))
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it 'raises a forbidden access error' do
        visit author_submission_final_submission_path(submission)
        # expect(page).to have_content 'You are not allowed to visit that page at this time, please contact your administrator'
        expect(page).to have_current_path(author_root_path)
      end
    end
  end
end
