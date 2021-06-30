RSpec.describe 'Author submission access_level', js: true do
  require 'integration/integration_spec_helper'

  let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, author: current_author }
  let(:committee_member1) { FactoryBot.create :committee_member, submission: submission }
  let(:committee_member2) { FactoryBot.create :committee_member, submission: submission }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

  before do
    oidc_authorize_author
    FactoryBot.create :format_review_file, submission: submission
    # create :final_submission_file, submission: submission
    submission.committee_members << committee_member1
    submission.committee_members << committee_member2
    visit author_submission_edit_final_submission_path(submission)
  end

  context 'graduate an honors authors can choose the access level', milsch: true do
    unless current_partner.milsch?
      it 'has an open_access radio button' do
        expect(page).not_to have_content('Access Level for this paper:')
        page.find("input#submission_access_level_open_access").click
        expect(page.find("#submission_access_level_open_access")).to be_checked
        expect(page).not_to have_content('Enter justification')
      end
      it 'has a restricted_to_institution radio button' do
        page.find("input#submission_access_level_restricted_to_institution").click
        expect(page.find("input#submission_access_level_restricted_to_institution")).to be_checked
        expect(page).not_to have_content('Enter justification')
        expect(page).not_to have_field('submission_invention_disclosures_attributes_0_id_number')
      end
      xit 'has a restricted radio button' do
        page.find("input#submission_access_level_restricted").click
        expect(page.find("input#submission_access_level_restricted")).to be_checked
        expect(page).not_to have_content('Enter justification')
        expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
        click_button('Submit final files for review')
        expect(page).to have_content('Invention disclosure number is required for Restricted submissions.')
        inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
        within inventions do
          fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
        end
        click_button('Submit final files for review')
        expect(page).not_to have_content('Invention disclosure number is required for Restricted submissions.')
      end
    end
  end

  context 'milsch authors cannot choose the access level', milsch: true do
    if current_partner.milsch?
      it 'has an open_access description' do
        expect(page).to have_content('Access Level for this paper: Open Access')
        expect(page.find("li.open_access")).to be_truthy
        expect(page).to have_content('Enter justification')
      end
      it 'has a restricted_to_institution description and restricted notes textarea' do
        expect(page.find("li.restricted_to_institution")).to be_truthy
        expect(page.find('textarea#submission_restricted_notes')).to be_truthy
        expect(page).to have_content('Enter justification')
      end
      it 'has a restricted radio button and field for invention disclosure' do
        expect(page.find("li.restricted")).to be_truthy
        expect(page).to have_field('submission_invention_disclosures_attributes_0_id_number')
        click_button('Submit final files for review')
        expect(page).not_to have_content('Invention disclosure number is required for Restricted submissions.')
        inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
        within inventions do
          fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
        end
      end
    end
  end
end
