RSpec.describe "Step 7: Waiting for Final Submission Response'", js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'waiting for final submission response'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:submission) do
      FactoryBot.create :submission, :waiting_for_final_submission_response, author: author, degree: degree
    end
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: submission.degree_type }
    let!(:degree) { FactoryBot.create :degree }

    context "visiting the 'Update Program Information' page" do
      it "raises a forbidden access error" do
        visit edit_author_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Provide Committee' page" do
      it "raises a forbidden access error" do
        visit new_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Committee' page" do
      it "raises a forbidden access error" do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Upload Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_format_review_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Program Information' page" do
      it "loads the page" do
        visit author_submission_program_information_path(submission)
        expect(page).to have_current_path(author_submission_program_information_path(submission))
      end
    end

    context "visiting the 'Review Committee' page" do
      it "loads the page" do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "loads the page" do
        visit author_submission_format_review_path(submission)
        expect(page).to have_current_path(author_submission_format_review_path(submission))
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "loads the page" do
        visit author_submission_final_submission_path(submission)
        expect(page).to have_current_path(author_submission_final_submission_path(submission))
      end
    end
  end
end
