RSpec.describe "Editing a released submission as an admin", js: true do
  require 'integration/integration_spec_helper'
  let!(:degree) { FactoryBot.create(:degree, name: "Master of Disaster", is_active: true) }
  let!(:program) { FactoryBot.create(:program, name: "Test Program", is_active: true) }
  let!(:approval_config) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default }

  describe 'making changes while a submission is published' do
    let!(:author) { FactoryBot.create(:author) }
    let!(:role) { CommitteeRole.second }
    let(:submission) { FactoryBot.create(:submission, :released_for_publication, author: author, semester: 'Fall', year: DateTime.now.year) }
    let(:committee) { create_committee(submission) }
    let(:invention_disclosures) { create(:invention_disclosure, submission) }

    before do
      oidc_authorize_admin
      visit admin_edit_submission_path(submission)
      page.find('div[data-target="#program-information"]').click
      fill_in "Title", with: "A Brand New TITLE"
      check "Allow completely upper-case words in title"
      select program.name, from: current_partner.program_label.to_s
      select degree.name, from: "Degree"
      select "Fall", from: "Semester Intending to Graduate"
      select 1.year.from_now.year, from: "Graduation Year"
      page.find('div[data-target="#committee"]').click
      sleep 1
      within('div.format') do
        within('#committee') do
          click_link("Add Committee Member")
          select role.name, from: "Committee role"
          fill_in "Name", with: "Bob Tester"
          fill_in "Email", with: "bob@email.com"
        end
      end
      page.find('div[data-target="#format-review-files"]').click
      within('#format-review-files') do
        click_link "Additional File"
        find('input[type="file"]', match: :first).set(fixture('format_review_file_01.pdf'))
      end

      fill_in "Format Review Notes to Student", with: "New review notes"
      fill_in "Admin notes", with: "Some admin notes"
    end

    it "Displays a message indicating the submission must be withdrawn to edit, and doesn't update changes", retry: 5 do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)

      expect(page).to have_content('In order to update a published submission, it must be withdrawn from publication. After withdrawing, the submission can be edited and re-published. Any changes made to the submission while it is released will NOT be saved. The withdraw button is at the bottom of the page.')
      expect(page).to have_button('Withdraw Publication')
      expect(page).not_to have_button('Update Metadata')
      fill_in "Abstract", with: "New abstract text"

      click_link "Additional Keyword"
      within '#keyword-fields' do
        all('textarea').last.set("Bananas")
      end

      page.find("#submission_access_level_restricted").click
      inventions = page.find(:css, 'div.form-group.string.optional.submission_invention_disclosures_id_number')
      within inventions do
        fill_in 'Invention Disclosure Number (Required for Restricted Access)', with: '1234'
      end

      within('#final-submission-information') do
        click_link "Additional File"
        find('input[type="file"]', match: :first).set(fixture('final_submission_file_01.pdf'))
      end

      fill_in "Final Submission Notes to Student", with: "New final notes"
      click_button "Withdraw Publication"
      # expect(page).to have_content "Submission for #{submission.author.first_name} #{submission.author.last_name} was successfully un-published"

      visit admin_edit_submission_path(submission)
      submission.reload
      expect(submission.status).to eq('waiting for publication release')
      expect(page).to have_button('Update Metadata')
      expect(page).to have_current_path(admin_edit_submission_path(submission))

      expect(page.find_field("Title").value).to eq submission.title
      expect(page.find_field("Allow completely upper-case words in title")).not_to be_checked
      page.find('div[data-target="#program-information"]').click
      expect(page.find_field(current_partner.program_label.to_s).value).to eq submission.program.id.to_s
      expect(page.find_field("Degree").value).to eq submission.degree.id.to_s
      expect(page.find_field("Semester Intending to Graduate").value).to eq "Fall"
      expect(page.find_field("Graduation Year").value).to eq DateTime.now.year.to_s
      page.find('div[data-target="#committee"]').click

      within('#committee') do
        expect { find("Committee role") }.to raise_error Capybara::ElementNotFound
      end

      within('div.format') do
        page.find('div[data-target="#format-review-files"]').click
        expect { find('a', text: 'format_review_file_01.pdf', visible: true) }.to raise_error Capybara::ElementNotFound
      end

      expect(page.find_field("Format Review Notes to Student").value).to eq submission.format_review_notes.to_s
      expect(page.find_field("Admin notes").value).to eq ""
      expect(page.find_field("Abstract").value).to eq submission.abstract.to_s

      within('#keyword-fields') do
        expect(page.all('textarea').last.value).to eq submission.keywords.last.word.to_s
      end

      expect(page.find_field('submission_access_level_restricted')).not_to be_checked

      within('#final-submission-file-fields') do
        expect(page).not_to have_link "final_submission_file_01.pdf"
      end

      expect(page.find_field("Final Submission Notes to Student").value).to eq submission.final_submission_notes.to_s
    end
  end

  describe "Remove from  submission to be released", js: true, retry: 5 do
    let!(:author) { FactoryBot.create(:author) }
    let!(:submission) { FactoryBot.create(:submission, :waiting_for_publication_release, author: author, degree: degree) }
    let!(:author_name) { submission.author.last_name }

    before do
      oidc_authorize_admin
      visit admin_edit_submission_path(submission)
    end

    it "Changes the status to 'waiting for final submission response' and also saves any updates" do
      expect(page).to have_content('Final Submission to be Released')
      expect(page).to have_button('Update Metadata Only')
      fill_in "Title", with: "A Better Title"
      click_button "Remove from Submission to be Released"
      expect(page).to have_current_path(admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved'))
      expect(page).not_to have_content "A Better Title"

      visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_submitted')
      sleep 1
      expect(page).to have_content('Final Submission is Submitted')
      expect(page).to have_content author_name
      click_link "A Better Title"
      expect(page).to have_content 'Final Submission Evaluation'
      expect(find(:css, 'input#submission_title').value).to eq('A Better Title')
      submission.reload
      expect(submission.status).to eq('waiting for final submission response')
    end
  end

  describe "Remove legacy record from  submission to be released", js: true, retry: 10 do
    it "Changes the status to 'final submission submitted' and also saves any updates" do
      legacy_submission = FactoryBot.create(:submission, :waiting_for_publication_release, degree: degree)
      legacy_submission.legacy_id = 888
      legacy_submission.save

      oidc_authorize_admin
      visit admin_edit_submission_path(legacy_submission)

      expect(page).to have_button('Update Metadata Only')
      # Some legacy records do not have titles
      fill_in "Title", with: ""
      click_button "Remove from Submission to be Released"
      expect(page).to have_current_path(admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_approved'))
      expect(page).not_to have_content "A Better Title"

      visit admin_submissions_index_path(degree_type: DegreeType.default, scope: 'final_submission_submitted')

      expect(page).to have_content legacy_submission.author.last_name
      visit admin_edit_submission_path(legacy_submission)
      expect(page).to have_content 'Final Submission Evaluation'
      expect(find(:css, 'input#submission_title').value).to eq('')
      legacy_submission.reload
      expect(legacy_submission.status).to eq('waiting for final submission response')
    end
  end
end
