RSpec.describe "Printing a graduate signatory page as an admin", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let(:submission_author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create(:submission, :waiting_for_format_review_response, semester: Semester.current.split(" ")[1], year: Semester.current.split(" ")[0]) }
  let(:admin) { FactoryBot.create :admin }

  before do
    create_committee(submission)
    oidc_authorize_admin
    visit admin_submissions_index_path(submission.degree_type.slug, 'format_review_submitted')
  end

  if current_partner.graduate?

    it "indicates the submission has not been printed when partner is graduate" do
      expect(page).to have_content('No')
    end

    it "updates 'Printed' to 'Yes' after printing" do
      click_link "Print Page"
      expect(page).to have_content("Yes")
    end
  else
    it 'does not contain a print button for other partners' do
      expect(page).not_to have_link('Print Page')
      expect(page).not_to have_content('Printed')
    end
  end
end
