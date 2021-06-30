RSpec.describe "when an admin releases a restricted submission for publication after 2 years", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let!(:submission) { FactoryBot.create :submission, :final_is_restricted, author: author }
  let(:committee) { create_committee(submission) }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }

  before do
    FileUtilityHelper.new.copy_test_file(Rails.root.join(final_submission_file.current_location))
    oidc_authorize_admin
    visit root_path
  end

  describe 'it should not update the number of released submissions' do
    let(:initial_released_count) { Submission.where(degree: submission.degree).released_for_publication.count }
    let(:initial_restricted_count) { Submission.where(degree: submission.degree).final_is_withheld.count }

    before do
      submission.released_for_publication_at = Time.zone.now.to_date + 2.years
      submission.released_metadata_at = Time.zone.now.to_date
      submission.status = 'released for publication'
      submission.access_level = 'restricted'
    end

    specify "submission status updates to 'released for publication'" do
      unreleased_location = Rails.root.join(final_submission_file.current_location)
      expect(File).to be_exist(unreleased_location)
      expect(Submission.where(degree: submission.degree).released_for_publication.count).to eql(initial_released_count)
      expect(Submission.where(degree: submission.degree).final_is_withheld.count).to eql(initial_restricted_count)
      expect(submission.released_for_publication_at).not_to be_nil
      visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
      sleep 1
      click_button 'Select Visible'
      expect(page).to have_content(I18n.t("#{current_partner.id}.admin_filters.final_withheld.title"), wait: 5)
      msg = page.accept_confirm do
        click_button 'Release as Open Access'
      end
      sleep 1
      expect(msg).to match(/#{author.first_name} #{author.last_name}/)
      expect(page).to have_content "successfully"
      submission.reload
      expect(submission.status).to eq('released for publication')
      expect(submission).to be_open_access
      expect(submission.released_for_publication_at).not_to be_nil
      expect(submission.released_for_publication_at.to_date).to eq Time.zone.today

      released_location = Rails.root.join(final_submission_file.current_location)
      expect(FileUtilityHelper.new).to be_file_was_moved(unreleased_location, released_location)

      visit admin_submissions_dashboard_path(DegreeType.default)
      released_count = page.find('a#released-for-publication .badge').text
      expect(released_count.to_i).to eql(initial_released_count)
      restricted_updated_count = page.find('#final-withheld .badge').text
      expect(restricted_updated_count.to_i).to eql(initial_restricted_count - 1)
      FileUtilityHelper.new.remove_test_file(released_location)
    end
  end
end
