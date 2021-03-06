RSpec.describe 'Step 2: Collecting Committee status', js: true do
  require 'integration/integration_spec_helper'

  describe "When status is 'collecting committee'" do
    before do
      oidc_authorize_author
    end

    let!(:author) { current_author }
    let!(:admin)  { current_admin }
    let!(:submission) { FactoryBot.create :submission, :collecting_committee, author: author }
    let(:master_thesis) { DegreeType.second }

    context "visiting the 'Author Submissions Index Page' page" do
      it 'loads the page' do
        visit author_submissions_path
        expect(page).to have_current_path(author_submissions_path)
        expect(page).to have_content(author.last_name)
      end
    end

    context "visiting the 'New Committee' page" do
      it "displays committee member edit page" do
        visit new_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(new_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Update Committee' page" do
      it "displays committee member edit page" do
        visit edit_author_submission_committee_members_path(submission)
        expect(page).to have_current_path(edit_author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Program Information' page" do
      it 'raises a forbidden access error' do
        visit "/author/submissions/#{submission.id}/program_information"
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Update Program Information' page" do
      it 'displays update program information page' do
        visit "/author/submissions/#{submission.id}/edit"
        expect(page).to have_current_path("/author/submissions/#{submission.id}/edit")
      end
    end

    context "visiting the 'Review Committee' page" do
      it "raises a forbidden access error" do
        visit author_submission_committee_members_path(submission)
        expect(page).to have_current_path(author_submission_committee_members_path(submission))
      end
    end

    context "visiting the 'Review Format Review Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_format_review_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Upload Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_edit_final_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end

    context "visiting the 'Review Final Submission Files' page" do
      it "raises a forbidden access error" do
        visit author_submission_final_submission_path(submission)
        expect(page).to have_current_path(author_root_path)
      end
    end
  end

  describe "author can delete a submission" do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: true }
    let(:author) { current_author }

    before do
      oidc_authorize_author
    end

    it "deletes the submission" do
      FactoryBot.create :submission, :collecting_format_review_files, author: author
      start_count = author.submissions.count
      expect(start_count > 0).to be_truthy
      visit author_root_path
      if !current_partner.graduate?
        click_link("delete")
        expect(author.submissions.count).to eq(start_count - 1)
      else
        expect(page).not_to have_link('delete')
      end
    end
  end
end
