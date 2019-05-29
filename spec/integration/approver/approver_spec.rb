RSpec.describe 'Approver approval page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:approval_configuration) { FactoryBot.create :approval_configuration }
  let(:committee_role) { FactoryBot.create :committee_role, id: 1 }

  before do
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    webaccess_authorize_approver
  end

  context 'approver matches committee member access_id' do
    before do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      visit "approver/committee_member/#{committee_member.id}"
    end

    let(:committee_member) { FactoryBot.create :committee_member, submission: submission, access_id: 'approverflow' }

    it 'can view approval page' do
      expect(page).to have_content('Committee Member Approval Page')
    end

    it 'can download final file submission' do
      num_windows = page.driver.browser.window_handles.count
      within("div#file_links") do
        final_link = page.find("a")
        final_link.trigger('click')
        sleep(3)
      end
      expect(page.driver.browser.window_handles.count).to eql(num_windows + 1)
    end

    it 'can edit status and notes' do
      within("form#edit_committee_member_#{committee_member.id}") do
        select "approved", from: 'committee_member_status'
        fill_in "committee_member_notes", with: 'Some notes.'
      end
      click_button 'Submit Review'
      sleep 3
      expect(page).to have_current_path(main_page_path)
      expect(CommitteeMember.find(committee_member.id).status).to eq 'approved'
      expect(CommitteeMember.find(committee_member.id).notes).to eq 'Some notes.'
    end
  end

  context 'approver does not match committee_member access_id' do
    it 'redirects to 401 error page when targeting review page' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).to have_current_path('/401')
    end

    it 'redirects to 401 error page when targeting submission download' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
      FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/files/final_submissions/#{final_submission_file.id}"
      expect(page).to have_current_path('/401')
    end
  end

  context 'approver is advisor and part of graduate school' do
    let(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'testuser' }

    before do
      visit "approver/committee_member/#{committee_member.id}"
    end

    it 'asks about federal funding used' do
      expect(page).to have_content('Were Federal Funds utilized for this submission?')
    end
  end

  context 'approver is not advisor' do
    it 'asks about federal funding used' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).not_to have_content('Were Federal Funds utilized for this submission?')
    end
  end

  context 'approver is not in Ldap' do
    it 'redirects to 401 error page' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).to have_current_path('/401')
    end
  end

  context 'approval is complete' do
    let(:submission1) { FactoryBot.create :submission, status: "waiting for final submission response" }
    let(:committee_member) { FactoryBot.create :committee_member, submission: submission1, access_id: 'testuser', status: "approved", notes: "this is the note", approved_at: DateTime.new(2019, 10, 10, 5, 5, 55) }

    before do
      visit "approver/committee_member/#{committee_member.id}"
    end

    it 'displays the committee members response' do
      expect(page).to have_content('approved')
      expect(page).to have_content('Review Completed on')
    end
    it 'displays the ultimate outcome of the submission' do
      expect(page).to have_content('Committee approved the submission')
    end
    it 'displays the help text message' do
      expect(page).to have_content('If your response needs to be altered')
    end
  end
end
