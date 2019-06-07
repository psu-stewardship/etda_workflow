RSpec.describe "Sending an email reminder", js: true do
  require 'integration/integration_spec_helper'

  let(:author) { FactoryBot.create :author }
  let(:submission1) { FactoryBot.create(:submission, :waiting_for_committee_review, author: author) }
  let(:submission2) { FactoryBot.create(:submission, :collecting_format_review_files, author: author) }
  let(:committee_member1) { FactoryBot.create(:committee_member) }
  let(:committee_member2) { FactoryBot.create(:committee_member) }

  before do
    submission1.committee_members << committee_member1
    submission2.committee_members << committee_member2
    webaccess_authorize_admin
  end

  context "when submission status is waiting for committee review" do
    before do
      visit admin_edit_submission_path(submission1)
    end

    it 'sends an email reminder if authorized to' do
      find("div[data-target='#committee']").click

      within('#committee') do
        expect(page).to have_content('Committee role')
        click_button 'Send Email Reminder'
      end
      expect { page.accept_confirm }.to change { WorkflowMailer.deliveries.count }.by 1
    end

    it 'does not send an email reminder if not authorized to' do
      committee_member1.update_attributes(last_reminder_at: DateTime.now)
      find("div[data-target='#committee']").click

      within('#committee') do
        expect(page).to have_content('Committee role')
        click_button 'Send Email Reminder'
      end
      expect { page.accept_confirm }.not_to(change { WorkflowMailer.deliveries.count })
    end
  end

  context 'when submission status is not waiting for committee approval' do
    before do
      visit admin_edit_submission_path(submission2)
    end

    it 'does not have send email reminder button' do
      find("div[data-target='#committee']").click

      within('#committee') do
        expect(page).to have_content('Committee role')
        expect(page).not_to have_content('Send Email Reminder')
      end
    end
  end
end