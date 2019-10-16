RSpec.describe "when an admin releases the submission for publication", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, author: author }
  let(:committee) { create_committee(submission) }
  let(:inbound_lion_path_record) { FactoryBot.create :inbound_lion_path_record }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }

  before do
    webaccess_authorize_admin
    visit root_path
    FileUtilityHelper.new.copy_test_file(Rails.root.join(final_submission_file.current_location))
  end

  context 'when open access', js: true do
    let(:initial_released_count) { Submission.where(degree: DegreeType.default).released_for_publication.count }

    it "updates the number of released submissions" do
      unreleased_location = Rails.root.join(final_submission_file.current_location)
      expect(File).to be_exist(unreleased_location)
      expect(Submission.where(degree: DegreeType.default).released_for_publication.count).to eq(initial_released_count)
      expect(submission.released_for_publication_at).to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      sleep(3)
      click_button 'Select Visible'
      expect(page).to have_content('Showing', wait: 5)
      page.find('h1', text: 'Final Submission to be Released', wait: 8)
      # select "#{Time.zone.now.year}", from: 'selected_date[year]'
      # select 'December', from: 'selected_date[month]'
      # select '30', from: 'selected_date[day]'
      sleep(8)
      page.find('#selected_date_year').select(Time.zone.now.year.to_s)
      page.find('#selected_date_month').select('December')
      page.find('#selected_date_day').select("30")
      expect(page).to have_button 'Release selected for publication'
      page.accept_confirm do
        click_button 'Release selected for publication'
      end
      # expect(page).to have_content "successfully"
      submission.reload
      released_location = Rails.root.join(final_submission_file.current_location)
      expect(FileUtilityHelper.new).to be_file_was_moved(unreleased_location, released_location)
      expect(submission.status).to eq 'released for publication'
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.strftime('%Y %m %d')).to eq "#{Time.zone.now.year} 12 30"
      expect(submission.released_metadata_at).to eq submission.released_for_publication_at
      visit admin_submissions_dashboard_path(DegreeType.default)
      sleep(3)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count + 1)
      FileUtilityHelper.new.remove_test_file(released_location)
      expect(WorkflowMailer.deliveries.first.subject).to match(/has been released/i)
    end
  end

  context 'when restricted (or restricted to institution)' do
    let(:initial_released_count) { Submission.where(degree: DegreeType.default).released_for_publication.count }

    it 'updates the number of released submissions should not change access_level' do
      submission.update_attributes(access_level: 'restricted_to_institution')
      unreleased_location = Rails.root.join(final_submission_file.current_location)
      expect(File).to be_exist(unreleased_location)
      expect(Submission.where(degree: DegreeType.default).released_for_publication.count).to eq(initial_released_count)
      expect(submission.released_for_publication_at).to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      sleep(3)
      click_button 'Select Visible'
      expect(page).to have_content('Showing', wait: 5)
      page.find('h1', text: 'Final Submission to be Released', wait: 8)
      # select "#{Time.zone.now.year}", from: 'selected_date[year]'
      # select 'December', from: 'selected_date[month]'
      # select '30', from: 'selected_date[day]'
      sleep(8)
      page.find('#selected_date_year').select(Time.zone.now.year.to_s)
      page.find('#selected_date_month').select('December')
      page.find('#selected_date_day').select("30")
      expect(page).to have_button 'Release selected for publication'
      page.accept_confirm do
        click_button 'Release selected for publication'
      end
      # expect(page).to have_content "successfully"
      submission.reload
      released_location = Rails.root.join(final_submission_file.current_location)
      expect(FileUtilityHelper.new).to be_file_was_moved(unreleased_location, released_location)
      expect(submission.status).to eq 'released for publication'
      expect(submission.access_level).to eq 'restricted_to_institution'
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.strftime('%Y %m %d')).to eq "#{Time.zone.now.year.to_i + 2} 12 30"
      expect(submission.released_metadata_at).to eq(submission.released_for_publication_at - 2.years)
      visit admin_submissions_dashboard_path(DegreeType.default)
      sleep(3)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count + 1)
      FileUtilityHelper.new.remove_test_file(released_location)
      expect(WorkflowMailer.deliveries.first.subject).to match(/metadata has been released/i)
    end

    it 'does not change access_level should it accidentally be released again' do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(nil)
      submission.update_attributes(access_level: 'restricted_to_institution')
      unreleased_location = Rails.root.join(final_submission_file.current_location)
      expect(File).to be_exist(unreleased_location)
      expect(Submission.where(degree: DegreeType.default).released_for_publication.count).to eq(initial_released_count)
      expect(submission.released_for_publication_at).to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
      sleep(3)
      click_button 'Select Visible'
      expect(page).to have_content('Showing', wait: 5)
      page.find('h1', text: 'Final Submission to be Released', wait: 8)
      # select "#{Time.zone.now.year}", from: 'selected_date[year]'
      # select 'December', from: 'selected_date[month]'
      # select '30', from: 'selected_date[day]'
      sleep(8)
      page.find('#selected_date_year').select(Time.zone.now.year.to_s)
      page.find('#selected_date_month').select('December')
      page.find('#selected_date_day').select("30")
      expect(page).to have_button 'Release selected for publication'
      page.accept_confirm do
        click_button 'Release selected for publication'
      end
      expect(page).to have_content "Internal Server Error"
      page.driver.browser.refresh
      submission.reload
      released_location = Rails.root.join(final_submission_file.current_location)
      expect(FileUtilityHelper.new).to be_file_was_moved(unreleased_location, released_location)
      expect(submission.status).to eq 'released for publication'
      expect(submission.access_level).to eq 'restricted_to_institution'
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.strftime('%Y %m %d')).to eq "#{Time.zone.now.year.to_i + 2} 12 30"
      expect(submission.released_metadata_at).to eq(submission.released_for_publication_at - 2.years)
      visit admin_submissions_dashboard_path(DegreeType.default)
      sleep(3)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count + 1)
      FileUtilityHelper.new.remove_test_file(released_location)
    end
  end
end
