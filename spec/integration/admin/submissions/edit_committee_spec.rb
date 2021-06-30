RSpec.describe "Editing committee member information", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let!(:author) { FactoryBot.create(:author) }
  let!(:submission) { FactoryBot.create(:submission, :waiting_for_committee_review, degree: degree, author: author) }
  let!(:degree) { FactoryBot.create(:degree, degree_type: DegreeType.default) }
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default }
  let!(:committee_role) { FactoryBot.create :committee_role, degree_type: DegreeType.default }

  before do
    create_committee submission
    submission.committee_members << FactoryBot.create(:committee_member, committee_role: committee_role)
    oidc_authorize_admin
  end

  it 'has specific content and records changes for certain updates', retry: 5 do
    visit admin_edit_submission_path(submission)
    committee_size = submission.committee_members.count
    find("div[data-target='#committee']").click
    sleep 1
    within('#committee') do
      within("select#submission_committee_members_attributes_0_committee_role_id") do
        CommitteeRole.where(degree_type: degree.degree_type).each do |option|
          expect(find("option[value='#{option[:id]}']").text).to eq(option[:name])
        end
      end
      last_committee_member_remove = find_all("a", text: "Remove Committee Member").last
      find("select#submission_committee_members_attributes_0_status").find(:option, 'Approved').select_option
      last_committee_member_remove.click
    end
    click_button 'Update Metadata'
    submission.reload
    find("div[data-target='#committee']").click
    sleep 1
    within('#committee') do
      expect(page).to have_content("Approved at: ")
    end
    expect(submission.committee_members.count).to eq(committee_size.to_i - 1)
    expect(submission.committee_members.first.status).to eq 'approved'
    expect(submission.committee_members.first.notes).to match(/changed Review Status to 'Approved'/)
  end

  context 'when committee member was created via lionpath import' do
    let(:lp_committee_member) do
      FactoryBot.create :committee_member, name: 'LP Tester',
                                           lionpath_updated_at: DateTime.now, committee_role: committee_role
    end

    before do
      submission.committee_members << lp_committee_member
    end

    context 'when no committee member is external to PSU' do
      it 'disables the name and committee role fields for this committee member (does not disable email)' do
        skip 'graduate only' unless current_partner.graduate?

        visit admin_edit_submission_path(submission)
        find("div[data-target='#committee']").click
        sleep 1
        within('#committee') do
          expect(find_all("select.role").last.value).to eq committee_role.id.to_s
          expect(find_all("select.role").last.disabled?).to eq true
          expect(find_all("input.ui-autocomplete-input").last.value).to eq 'LP Tester'
          expect(find_all("input.ui-autocomplete-input").last.disabled?).to eq true
          expect(find_all("input.email").last.disabled?).to eq false
        end
      end
    end

    context 'when one of the committee members is external to PSU' do
      let(:external_role) { FactoryBot.create :committee_role, name: 'Special Member', code: 'S', degree_type: DegreeType.default }
      let!(:committee_member) do
        FactoryBot.create :committee_member, submission: submission, committee_role: external_role,
                                             lionpath_updated_at: DateTime.now, external_to_psu_id: 'mgc25',
                                             access_id: 'mgc25', name: 'Member Committee', email: 'mgc25@psu.edu'
      end

      it 'displays an open form' do
        skip 'graduate only' unless current_partner.graduate?

        visit admin_edit_submission_path(submission)
        find("div[data-target='#committee']").click
        sleep 1
        within('#committee') do
          expect(find_all("select.role").last.value).to eq external_role.id.to_s
          expect(find_all("select.role").last.disabled?).to eq false
          expect(find_all("input.ui-autocomplete-input").last.value).to eq committee_member.name
          expect(find_all("input.ui-autocomplete-input").last.disabled?).to eq false
          expect(find_all("input.email").last.disabled?).to eq false
          expect(find_all("input.email").last.value).to eq committee_member.email
        end
      end
    end
  end
end
