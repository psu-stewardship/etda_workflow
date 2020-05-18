RSpec.describe "Editing format review and final submissions as an admin", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, degree_type: degree.degree_type) }
  let!(:role) { CommitteeRole.second }
  let!(:author) { FactoryBot.create(:author, :no_lionpath_record) }
  let(:submission) { FactoryBot.create(:submission, :collecting_committee, author: author) }
  let(:admin) { FactoryBot.create :admin }
  let(:final_submission) { FactoryBot.create(:submission, :waiting_for_final_submission_response, author: author) }

  before do
    webaccess_authorize_admin
  end

  it "Saves the updated submission data for a submission with status collecting committee", retry: 5 do
    visit admin_edit_submission_path(submission)
    check "Allow completely upper-case words in title"
    fill_in "Title", with: "A Brand New TITLE"
    select program.name, from: current_partner.program_label.to_s
    select degree.name, from: "Degree"
    select "Fall", from: "Semester Intending to Graduate"
    select 1.year.from_now.year, from: "Graduation Year"

    click_link "Add Committee Member"
    within('#committee') do
      select role.name, from: "Committee role"
      fill_in "Name", with: "Bob Tester"
      fill_in "Email", with: "bob@email.com"
    end
    # page.find('div[data-target="#format-review-files"]').click
    within('#format-review-files') do
      click_link "Additional File"
      all('input[type="file"]').first.set(fixture('format_review_file_01.pdf'))
      all('input[type="file"]').last.set(fixture('format_review_file_02.pdf'))
    end

    find('#submission_federal_funding_true').click
    fill_in "Format Review Notes to Student", with: "New review notes"
    fill_in "Admin notes", with: "Some admin notes"

    click_button "Update Metadata"
    visit admin_edit_submission_path(submission)
    page.find('div[data-target="#program-information"]').click
    expect(page).to have_current_path(admin_edit_submission_path(submission))
    expect(page.find_field("Title").value).to eq "A Brand New TITLE"
    expect(page.find_field("Allow completely upper-case words in title")).to be_checked
    expect(page.find_field(current_partner.program_label.to_s).value).to eq program.id.to_s
    expect(page.find_field("Degree").value).to eq degree.id.to_s
    expect(page.find_field("Semester Intending to Graduate").value).to eq "Fall"
    expect(page.find_field("Graduation Year").value).to eq 1.year.from_now.year.to_s
    expect(page.find_field("submission_federal_funding_true")).to be_checked

    within('#committee') do
      expect(page.find_field("Committee role").value).to eq role.id.to_s
      expect(page.find_field("Name").value).to eq "Bob Tester"
      expect(page.find_field("Email").value).to eq "bob@email.com"
    end

    within('#format-review-files') do
      expect(page).to have_link "format_review_file_01.pdf"
      expect(page).to have_link "format_review_file_02.pdf"
    end

    expect(page.find_field("Format Review Notes to Student").value).to eq "New review notes"
    expect(page.find_field("Admin notes").value).to eq "Some admin notes"

    within('#format-review-files') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.trigger('click')
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    # expect(page).to have_content('success')
    visit admin_edit_submission_path(submission)
    expect(page).to have_link "format_review_file_02.pdf"
    expect(page).not_to have_link "format_review_file_01.pdf"
  end

  it 'Allows admin to upload and delete final submission files' do
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      click_link "Additional File"
      all('input[type="file"]').first.set(fixture('final_submission_file_01.pdf'))
    end
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.trigger('click')
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
  end
  it 'Allows admin to upload multiple final submission files' do
    visit admin_edit_submission_path(final_submission)
    expect(page).not_to have_link('final_submission_file_01.pdf')
    expect(page).not_to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      click_link "Additional File"
      all('input[type="file"]').first.set(fixture('final_submission_file_01.pdf'))

      click_link "Additional File"
      all('input[type="file"]').last.set(fixture('final_submission_file_01.pdf'))
    end
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
    expect(page).to have_link('final_submission_file_01.pdf')
    within('#final-submission-information') do
      delete_link = find_all('a#file_delete_link').first
      delete_link.trigger('click')
    end
    expect(page).to have_content("Marked for deletion [undo]")
    click_button 'Update Metadata'
    visit admin_edit_submission_path(final_submission)
    expect(page).to have_link('final_submission_file_01.pdf')
  end

  it 'Allows admin to edit final submission content' do
    visit admin_edit_submission_path(final_submission)
    within('#final-submission-information') do
      click_link "Additional File"
      all('input[type="file"]').first.set(fixture('final_submission_file_01.pdf'))
    end
    find('#submission_access_level_restricted').click
    find('#submission_federal_funding_false').click
    fill_in 'submission_invention_disclosures_attributes_0_id_number', with: 12345
    fill_in 'Admin notes', with: 'Some Notes', exact: true
    click_button 'Update Metadata'
    expect(Submission.find(final_submission.id).admin_notes).to eq 'Some Notes'
    expect(Submission.find(final_submission.id).federal_funding).to eq false
    expect(Submission.find(final_submission.id).restricted?).to eq true
  end

  describe 'has link to audit page' do
    let!(:file) { FactoryBot.create :final_submission_file, submission: final_submission }

    it 'directs to audit page with audit content' do
      visit admin_edit_submission_path(final_submission)
      click_link 'View Printable Audit'
      expect(page).to have_content("#{final_submission.degree.degree_type.name} Audit")
      expect(page).to have_link(file.asset_identifier.to_s)
      expect(page).to have_content("Committee Approval Status:")
      expect(page).to have_content("Committee Member Reviews")
      expect(page).to have_content("Approved at")
    end
  end
end
