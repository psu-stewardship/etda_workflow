RSpec.describe "when an admin views the final submission is pending bucket", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission) do
    FactoryBot.create :submission,
                      :waiting_for_committee_review,
                      author: author,
                      semester: Semester.current.split(" ")[1],
                      year: Semester.current.split(" ")[0]
  end

  before do
    FactoryBot.create :submission,
                      :waiting_for_head_of_program_review,
                      author: author, semester: Semester.current.split(" ")[1],
                      year: Semester.current.split(" ")[0]
    oidc_authorize_admin
    visit admin_submissions_index_path(submission.degree.degree_type, :final_submission_pending)
  end

  it 'has pending heading and title links' do
    expect(page).to have_content "Final Submission is Pending"
    expect(page).to have_link submission.title
  end

  describe 'selecting a submission' do
    it 'has button to "Reject & return to author"' do
      create_committee(submission)
      click_link submission.title
      click_button 'Reject & return to author'
      page.driver.browser.switch_to.alert.accept
      sleep 5
      submission.reload
      expect(submission.status).to eq 'waiting for committee review rejected'
    end
  end
end
