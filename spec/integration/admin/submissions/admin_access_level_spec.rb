RSpec.describe 'Admin submission access_level', js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response, degree: degree }
  let!(:committee_member1) { FactoryBot.create :committee_member, submission: submission, committee_role: CommitteeRole.first }
  let!(:committee_member2) { FactoryBot.create :committee_member, submission: submission, committee_role: CommitteeRole.third }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_configuration) do
    FactoryBot.create :approval_configuration,
                      head_of_program_is_approving: true,
                      use_percentage: false,
                      configuration_threshold: 0,
                      degree_type: DegreeType.default
  end

  before do
    FactoryBot.create :format_review_file, submission: submission
    FactoryBot.create :final_submission_file, submission: submission
    submission.committee_members << committee_member1
    submission.committee_members << committee_member2
    submission.access_level = 'open_access'
    oidc_authorize_admin
    visit admin_edit_submission_path(submission)
  end

  context 'admin users can choose the access level', milsch: true do
    it 'has an open_access radio button' do
      page.find("input#submission_access_level_open_access").click
      expect(find("#submission_access_level_open_access")).to be_checked
      expect(page).to have_content('Enter justification') if current_partner.milsch?
    end
    it 'has a restricted_to_institution radio button' do
      page.find("input#submission_access_level_restricted_to_institution").click
      expect(page.find("input#submission_access_level_restricted_to_institution")).to be_checked
      if current_partner.milsch?
        expect(page).to have_content('Enter justification')
        expect(page.find('textarea#submission_restricted_notes')).to be_truthy
      end
      expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
    end
    it 'has a restricted radio button' do
      page.find("input#submission_access_level_restricted").click
      expect(page.find("input#submission_access_level_restricted")).to be_checked
      click_button('Update Metadata Only')
      expect(page).to have_content('Enter justification') if current_partner.milsch?
      expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
      inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
      within inventions do
        fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
      end
      click_button('Update Metadata Only')
      expect(page).not_to have_content('Invention disclosure number is required for Restricted submissions.')
    end
  end
end
