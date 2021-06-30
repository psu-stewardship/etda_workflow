RSpec.describe 'Approver approval page', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, created_at: Time.zone.now }
  let(:submission1) { FactoryBot.create :submission, :waiting_for_final_submission_response, created_at: Time.zone.now }
  let(:submission2) { FactoryBot.create :submission, :waiting_for_publication_release, committee_review_accepted_at: DateTime.now, created_at: Time.zone.now }
  let(:submission3) { FactoryBot.create :submission, :waiting_for_publication_release, committee_review_rejected_at: DateTime.now, created_at: Time.zone.now }
  let(:submission4) { FactoryBot.create :submission, :waiting_for_publication_release, created_at: Time.zone.now }
  let(:final_submission_file) { FactoryBot.create :final_submission_file, submission: submission }
  let(:approval_configuration) { FactoryBot.create :approval_configuration, head_of_program_is_approving: false }
  let(:committee_role) { FactoryBot.create :committee_role, name: "Dissertation Advisor/Co-Advisor" }
  let(:committee_role_not_advisor) { FactoryBot.create :committee_role, name: "Just Normal Member" }

  before do
    submission.final_submission_files << final_submission_file
    submission.degree.degree_type.approval_configuration = approval_configuration
    oidc_authorize_approver
  end

  context 'approver matches committee member access_id' do
    before do
      committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
      visit "approver/committee_member/#{committee_member.id}"
    end

    let(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }

    it 'has link to contact us' do
      expect(page).to have_content('Contact Us')
    end

    it 'can view approval page' do
      expect(page).to have_content('Submission Details')
    end

    it 'can see access level' do
      expect(page).to have_content('Open Access')
    end

    it 'can see other committee members reviews' do
      expect(page).to have_content('Committee Reviews')
    end

    it 'can download final file submission' do
      num_windows = page.driver.browser.window_handles.count
      within("div#file_links") do
        final_link = page.find("a")
        final_link.click
      end
      expect(page.driver.browser.window_handles.count).to eql(num_windows + 1)
    end

    it 'can edit status and notes' do
      allow(CommitteeMember).to receive(:program_head).with(submission).and_return(FactoryBot.create(:committee_member))
      within("form#edit_committee_member_#{committee_member.id}") do
        find(:css, "#committee_member_status_approved").set true
        fill_in "committee_member_notes", with: 'Some notes.'
        find(:css, "#committee_member_federal_funding_used_true").set true if current_partner.graduate?
      end
      click_button 'Submit Review'
      expect(page).to have_current_path(approver_root_path)
      expect(CommitteeMember.find(committee_member.id).status).to eq 'approved'
      expect(CommitteeMember.find(committee_member.id).notes).to eq 'Some notes.'
    end

    context 'approver is advisor and part of graduate school' do
      it 'asks about federal funding used' do
        expect(page).to have_content('Were Federal Funds utilized for this submission?') if current_partner.graduate?
      end
    end

    context 'approver is not advisor' do
      it 'asks about federal funding used' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role_not_advisor, submission: submission, access_id: 'approverflow'

        visit "approver/committee_member/#{committee_member.id}"
        expect(page).not_to have_content('Were Federal Funds utilized for this submission?')
      end
    end
  end

  context 'committee review is complete' do
    context 'approval is approved' do
      it 'displays the committee members response' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role, submission: submission2, access_id: 'approverflow'
        committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
        submission2.degree.degree_type.approval_configuration = approval_configuration
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content('approved')
        expect(page).to have_content('Review Completed on')
      end
    end

    context 'approval is rejected' do
      it 'displays the committee members response' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role, submission: submission3, access_id: 'approverflow'
        committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
        submission3.degree.degree_type.approval_configuration = approval_configuration
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('rejected')
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content('rejected')
        expect(page).to have_content('Review Completed on')
      end
    end

    context 'submission is legacy' do
      it 'displays a message' do
        committee_member = FactoryBot.create :committee_member, committee_role: committee_role, submission: submission4, access_id: 'approverflow'
        committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
        submission4.degree.degree_type.approval_configuration = approval_configuration
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('none')
        visit "approver/committee_member/#{committee_member.id}"

        expect(page).to have_content('This submission was processed')
      end
    end
  end

  context 'approver does not match committee_member access_id' do
    it 'redirects to 401 error page when targeting review page' do
      committee_member = FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/committee_member/#{committee_member.id}"
      expect(page).to have_current_path('/401')
    end

    it 'redirects to 401 error page when targeting submission download' do
      FactoryBot.create :committee_member, submission: submission, access_id: 'testuser'

      visit "approver/files/final_submissions/#{final_submission_file.id}"
      expect(page).to have_current_path('/401')
    end
  end

  context 'access level tooltip' do
    let(:committee_member) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }

    before do
      committee_member.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
    end

    context 'submission is open access' do
      it "does display help text" do
        submission.update_attribute :access_level, 'open_access'
        visit "approver/committee_member/#{committee_member.id}"

        find('a[data-toggle="tooltip"]').hover
        expect(page).to have_content("Allows free worldwide")
      end
    end

    context 'submission is restricted' do
      it "does display help text" do
        submission.update_attribute :access_level, 'restricted'
        visit "approver/committee_member/#{committee_member.id}"

        find('a[data-toggle="tooltip"]').hover
        expect(page).to have_content("Restricts the entire work")
      end
    end

    context 'submission is restricted_to_institution' do
      it "does display help text" do
        submission.update_attribute :access_level, 'restricted_to_institution'
        visit "approver/committee_member/#{committee_member.id}"

        find('a[data-toggle="tooltip"]').hover
        expect(page).to have_content("Access restricted to")
      end
    end
  end

  context "advisor is also a committee member" do
    let!(:committee_member1) { FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow' }
    let!(:committee_member2) { FactoryBot.create :committee_member, committee_role: committee_role_not_advisor, submission: submission, access_id: 'approverflow' }

    before do
      submission.committee_members << [committee_member2, committee_member1]
      submission.reload
      committee_member1.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
      committee_member2.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id
    end

    it "redirects to the advisor page when trying to access the committee member page" do
      visit approver_path committee_member2
      expect(page).to have_current_path approver_path committee_member1
    end

    it "does not redirect if already advisor" do
      committee_member3 = FactoryBot.create :committee_member, committee_role: committee_role, submission: submission, access_id: 'approverflow'
      submission.committee_members << committee_member3
      submission.reload
      committee_member3.update_attribute :approver_id, Approver.find_by(access_id: 'approverflow').id

      visit approver_path committee_member3
      expect(page).to have_current_path approver_path committee_member3
    end
  end
end
