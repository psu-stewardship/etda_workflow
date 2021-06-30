RSpec.describe 'actions that send an email notifying users of an access level update on a submission', js: true do
  require 'integration/integration_spec_helper'

  describe 'updating the access level for an approved final submission' do
    # admin = FactoryBot.create :admin, site_administrator: true, administrator: true

    before do
      oidc_authorize_admin
    end

    it 'sends an email to the appropriate people with the updated access level information' do
      author = FactoryBot.create :author
      submission = FactoryBot.create :submission, :final_is_restricted, author: author
      start_count = ActionMailer::Base.deliveries.count
      visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
      sleep 1
      click_button 'Select Visible'
      page.accept_confirm do
        click_button 'Release as Open Access'
      end
      sleep 1
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
      email_to_address = submission.author.alternate_email_address || submission.author.psu_email_address
      open_email(email_to_address)
      expect(current_email.body).to match(/Old Availability - Restricted/i)
      expect(current_email.body).to match(/New Availability - Open Access/i)
      expect(current_email).to have_content submission.year
      expect(current_email).to have_content submission.author_full_name
      expect(current_email).to have_content submission.title
      expect(current_email.subject).to match(/Access Level for your submission has been updated/i)
      expect(current_email.cc).not_to be_blank
      expect(current_email.from).to eq [current_partner.email_address]
    end
  end

  describe 'bulk releasing submissions', js: true do
    before do
      oidc_authorize_admin
    end

    it 'sends an email for each submission released with the updated access level information' do
      submission1 = FactoryBot.create :submission, :final_is_restricted
      submission2 = FactoryBot.create :submission, :final_is_restricted
      start_count = ActionMailer::Base.deliveries.count
      visit admin_submissions_index_path(DegreeType.default, 'final_withheld')
      sleep 1
      click_button 'Select Visible'
      click_button "Release as Open Access"
      page.driver.browser.switch_to.alert.accept
      sleep 1
      email1_to_address = submission1.author.alternate_email_address || submission1.author.psu_email_address
      email2_to_address = submission2.author.alternate_email_address || submission2.author.psu_email_address
      submission1_email = open_email(email1_to_address)
      submission2_email = open_email(email2_to_address)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 2)
      expect(submission1_email.body).to match(/Old Availability - Restricted/i)
      expect(submission1_email.body).to match(/New Availability - Open Access/i)
      expect(submission1_email).to have_content submission1.year
      expect(submission1_email).to have_content submission1.author_full_name
      expect(submission1_email).to have_content submission1.title
      expect(submission1_email.subject).to match(/Access Level for your submission has been updated/i)
      expect(submission1_email.cc).to eq [AccessLevelUpdatedEmail.otm_email_address]
      expect(submission1_email.from).to eq [current_partner.email_address]
      expect(submission2_email.body).to match(/Old Availability - Restricted/i)
      expect(submission2_email.body).to match(/New Availability - Open Access/i)
      expect(submission2_email).to have_content submission2.year
      expect(submission2_email).to have_content submission2.author_full_name
      expect(submission2_email).to have_content submission2.title
      expect(submission2_email.subject).to match(/Access Level for your submission has been updated/i)
      expect(submission2_email.cc).to eq [AccessLevelUpdatedEmail.otm_email_address]
      expect(submission2_email.from).to eq [current_partner.email_address]
    end
  end
end
