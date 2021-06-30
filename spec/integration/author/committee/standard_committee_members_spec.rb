RSpec.describe 'The standard committee form for authors', js: true do
  require 'integration/integration_spec_helper'

  let(:author) { current_author }

  if current_partner.graduate?
    let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author, degree: degree }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.find_by(slug: 'master_thesis') }
    let!(:program_chair) { FactoryBot.create :program_chair, program: submission.program, campus: submission.campus }
  else
    let(:submission) { FactoryBot.create :submission, :collecting_committee, author: author }
  end

  before do
    oidc_authorize_author
    visit new_author_submission_committee_members_path(submission)
  end

  describe "submit empty form" do
    it "displays validation errors" do
      click_button 'Save and Continue Editing'
      expect(page).to have_content("can't be blank")
      click_button "Save and Continue Submission"
      expect(page).to have_content("can't be blank")
    end
  end

  describe "Cancel" do
    it "does not save the committee" do
      expect(page).to have_content('Add Committee')
      submission.required_committee_roles.count.times do |i|
        if i == 0 && current_partner.graduate?
          select("#{program_chair.first_name} #{program_chair.last_name}", from: "program-head-name")
          next
        end

        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        fill_in "submission_committee_members_attributes_#{i}_email", with: "buck@hotmail.com"
      end
      click_link('Cancel')
      expect(page).to have_content('My Submissions')
      submission.reload
    end
  end

  describe "save and continue submission" do
    context 'when submission is a master_thesis' do
      it "allows editing and submission of committee", honors: true, milsch: true do
        expect(page).to have_link('Add Committee Member')
        # visit new_author_submission_committee_members_path(submission)
        submission.required_committee_roles.count.times do |i|
          if i == 0 && current_partner.graduate?
            expect(find("#member-email").readonly?).to eq true
            select("#{program_chair.first_name} #{program_chair.last_name}", from: "program-head-name")
            expect(find("#member-email").value).to eq program_chair.email
            next
          end

          fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
          page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
        end
        click_button 'Save and Continue Submission'
        expect(page).to have_content('My Submissions')
        submission.reload
        expect(submission.committee_members.count).to eq(submission.required_committee_roles.count)
        expect(submission.committee_members.first.access_id).to eq('pbm123') unless current_partner.graduate?
        expect(submission.committee_members.second.access_id).to eq('pbm123') if current_partner.graduate?
        visit author_submission_committee_members_path(submission)
        submission.required_committee_roles.count.times do |i|
          if i == 0 && current_partner.graduate?
            expect(page).to have_content(program_chair.first_name + ' ' + program_chair.last_name)
            expect(page).to have_content(program_chair.email)
            next
          end
          # expect(page).to have_content role.name
          name = "Professor Buck Murphy #{i}"
          email = "buck@hotmail.com"
          expect(page).to have_content(name)
          expect(page).to have_content(email)
        end
      end
    end

    context 'when submission is a dissertation' do
      context 'when lionpath committee is present' do
        let!(:submission_2) { FactoryBot.create :submission, :collecting_committee, author: author, degree: degree_2 }
        let!(:degree_2) { FactoryBot.create :degree, degree_type: DegreeType.default }
        let!(:program_chair2) { FactoryBot.create :program_chair, program: submission_2.program, campus: submission_2.campus }
        let!(:program_chair3) { FactoryBot.create :program_chair, program: submission_2.program, campus: submission_2.campus, role: 'Professor in Charge' }
        let!(:approval_config) do
          FactoryBot.create :approval_configuration, head_of_program_is_approving: true,
                                                     degree_type: DegreeType.default
        end
        let!(:committee_member_1) { FactoryBot.create :committee_member, submission: submission_2, lionpath_updated_at: DateTime.now }
        let!(:committee_member_2) { FactoryBot.create :committee_member, submission: submission_2, lionpath_updated_at: DateTime.now }
        let!(:committee_member_3) { FactoryBot.create :committee_member, submission: submission_2, lionpath_updated_at: DateTime.now }

        it 'disables committee form and allows submission of committee' do
          skip 'graduate only' unless current_partner.graduate?

          visit new_author_submission_committee_members_path(submission_2)
          submission_2.committee_members.count.times do |i|
            expect(find("#submission_committee_members_attributes_#{i}_name").value).to eq('Professor Buck Murphy')
            expect(find("#submission_committee_members_attributes_#{i}_name").disabled?).to eq true
            expect(find("#submission_committee_members_attributes_#{i}_email").readonly?).to eq true
          end
          expect(find("#member-email").readonly?).to eq true
          select("#{program_chair3.first_name} #{program_chair3.last_name}", from: "program-head-name")
          expect(find("#member-email").value).to eq program_chair3.email
          expect(find_all(".hidden", visible: false)[-3].value)
            .to eq submission_2.degree_type.committee_roles
                               .find_by(name: 'Professor in Charge/Director of Graduate Studies').id.to_s
          click_link 'Add Special Signatory'
          fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
          within fields_for_last_committee_member do
            expect(find("div.select").find_all("option").count).to eq 1
            select 'Special Signatory', from: 'Committee role'
            fill_in "Name", with: "Extra Member"
            fill_in "Email", with: "extra_member@example.com"
          end
          expect { click_button 'Save and Continue Submission' }.to change { submission_2.committee_members.count }.by 2
          submission_2.reload
          expect(submission_2.status).to eq 'collecting format review files'
          expect(submission_2.program_head.committee_role.name).to eq 'Professor in Charge/Director of Graduate Studies'
          expect(submission_2.program_head.access_id).to eq program_chair3.access_id
        end

        context 'when a committee member is external to PSU' do
          let(:external_role) { FactoryBot.create :committee_role, name: 'Special Member', code: 'S', degree_type: DegreeType.default }

          context 'when the committee member has been updated' do
            let!(:committee_member_4) do
              FactoryBot.create :committee_member, submission: submission_2, committee_role: external_role,
                                                   lionpath_updated_at: DateTime.now, external_to_psu_id: 'mgc25',
                                                   access_id: 'mgc25', name: 'Member Committee', email: 'mgc25@psu.edu'
            end

            it 'has an open and blank form for this committee member' do
              skip 'graduate only' unless current_partner.graduate?

              visit edit_author_submission_committee_members_path(submission_2)
              num = submission_2.committee_members.count - 1
              expect(find("#submission_committee_members_attributes_#{num}_name").disabled?).to eq false
              expect(find("#submission_committee_members_attributes_#{num}_name").value).to eq ''
              expect(find("#submission_committee_members_attributes_#{num}_email").readonly?).to eq false
              expect(find("#submission_committee_members_attributes_#{num}_email").value).to eq ''
            end
          end

          context 'when the committee member has been updated' do
            let!(:committee_member_4) do
              FactoryBot.create :committee_member, submission: submission_2, committee_role: external_role,
                                                   lionpath_updated_at: DateTime.now, external_to_psu_id: 'mgc25',
                                                   access_id: nil, name: 'Test Person', email: 'test@email.com'
            end

            it 'has an open filled out form for this committee member' do
              skip 'graduate only' unless current_partner.graduate?

              visit edit_author_submission_committee_members_path(submission_2)
              num = submission_2.committee_members.count - 1
              expect(find("#submission_committee_members_attributes_#{num}_name").disabled?).to eq false
              expect(find("#submission_committee_members_attributes_#{num}_name").value).to eq committee_member_4.name
              expect(find("#submission_committee_members_attributes_#{num}_email").disabled?).to eq false
              expect(find("#submission_committee_members_attributes_#{num}_email").value).to eq committee_member_4.email
            end
          end
        end
      end

      context 'when lionpath committee is not present' do
        let(:submission_2) do
          FactoryBot.create :submission, :collecting_committee,
                            author: author, degree: degree_2, lionpath_updated_at: DateTime.now
        end
        let(:degree_2) { FactoryBot.create :degree, degree_type: DegreeType.default }
        let(:head_role_2) { CommitteeRole.find_by(degree_type: DegreeType.default, name: 'Program Head/Chair', is_program_head: true) }
        let(:head_member_2) do
          FactoryBot.create :committee_member, committee_role: head_role_2, is_required: true,
                                               is_voting: false, name: 'Test Tester', email: 'abc123@psu.edu',
                                               lionpath_updated_at: DateTime.now, submission_id: submission_2.id
        end
        let!(:approval_config) do
          FactoryBot.create :approval_configuration, head_of_program_is_approving: true,
                                                     degree_type: DegreeType.default
        end

        it 'does not allow submission of committee and raises error' do
          skip 'graduate only' unless current_partner.graduate?

          visit edit_author_submission_committee_members_path(submission_2)
          click_link 'Add Special Signatory'
          fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
          within fields_for_last_committee_member do
            expect(find("div.select").find_all("option").count).to eq 1
            select 'Special Signatory', from: 'Committee role'
            fill_in "Name", with: "Extra Member"
            fill_in "Email", with: "extra_member@example.com"
          end
          expect { click_button 'Save and Continue Submission' }.to change { submission_2.committee_members.count }.by 0
          expect(page).to have_content 'Your committee is not complete'
        end
      end
    end
  end

  describe "filling in committee members", js: true, honors: true, milsch: true do
    before do
      @email_list = []
      submission.required_committee_roles.count.times do |i|
        if i == 0 && current_partner.graduate?
          select("#{program_chair.first_name} #{program_chair.last_name}", from: "program-head-name")
          next
        end

        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
        @email_list << "buck@hotmail.com"
      end
      click_button 'Save and Continue Editing'
    end

    it 'allows an additional committee member to be added', js: true do
      # expect(page).to have_content('successfully')
      expect(page).to have_link('Add Committee Member')
      assert_equal submission.committee_email_list, @email_list.uniq unless current_partner.graduate?
      click_link 'Add Committee Member'
      expect(page).to have_link('[ Remove Committee Member ]')
      fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
      last_role = submission.required_committee_roles.last.name
      within fields_for_last_committee_member do
        expect { select 'Program Head/Chair', from: 'Committee role' }.to raise_error Capybara::ElementNotFound if current_partner.graduate?
        select last_role, from: 'Committee role'
        fill_in "Name", with: "Extra Member"
        fill_in "Email", with: "extra_member@example.com"
      end
      expect { click_button 'Save and Continue Editing' }.to change { submission.committee_members.count }.by 1
      submission.reload
      expect(submission.status).to eq 'collecting format review files'
      expect(submission.committee_provided_at).not_to be_nil
      expect(submission.committee_members.last.is_voting).to eq(true)
      # expect(page).to have_content('successfully')
    end

    it 'sets is_voting to false for special signatory' do
      skip 'Graduate Only' unless current_partner.graduate?

      click_link 'Add Committee Member'
      fields_for_last_committee_member = all('form.edit_submission div.nested-fields').last
      within fields_for_last_committee_member do
        select "Special Signatory", from: 'Committee role'
        fill_in "Name", with: "Extra Member"
        fill_in "Email", with: "extra_member@example.com"
      end
      click_button 'Save and Continue Editing'
      submission.reload
      expect(submission.committee_members.last.is_voting).to eq(false)
    end
  end

  describe "Remove an optional committee member", js: true do
    before do
      submission.committee_members = []
      submission.status = 'collecting format review files'
      roles = CommitteeRole.where(degree_type_id: submission.degree.degree_type.id, num_required: 1)
      FactoryBot.create(:program_chair, program: submission.program, campus: submission.campus,
                                        first_name: 'Professor', last_name: 'Buck Murphy 0')
      submission.required_committee_roles.count.times do |i|
        submission.committee_members << FactoryBot.create(:committee_member, name: "Professor Buck Murphy #{i}",
                                                                             email: "buck@hotmail.com",
                                                                             is_required: true,
                                                                             committee_role_id: roles[i].id)
      end
      submission.committee_members << FactoryBot.create(:committee_member, name: 'I am Special',
                                                                           email: 'special@person.com', is_required: false,
                                                                           committee_role_id: CommitteeRole.where(name: 'Special Signatory').first.id)
      submission.save!
      visit edit_author_submission_committee_members_path(submission)
    end

    it "can delete an optional committee member" do
      expect(page).to have_field('Name', with: 'I am Special')
      click_link "Remove Committee Member"
      click_button 'Save and Continue Editing'
      # expect(page).to have_content('successfully')
      submission.reload
      # expect(page).to have_content('Committee updated successfully')
      expect(page).not_to have_field('Name', with: 'I am Special')
    end
    # specify "submission status updates to 'collecting format review files'" do
    #   submission.reload
    #   expect(submission.committee_members.count).to eq submission.required_committee_roles.count
    # end
  end

  describe "typing in part of a known committee member's name", :ldap do
    let(:dropdown_items) { page.all("ul.ui-autocomplete li") }

    let(:dropdown_item_for_alex) do
      dropdown_items.find { |option| option.text =~ /Alex James Kiessling/ }
    end

    before do
      (1..submission.required_committee_roles.count - 1).each do |i|
        fill_in "submission_committee_members_attributes_#{i}_name", with: "Professor Buck Murphy #{i}"
        page.execute_script("document.getElementById('submission_committee_members_attributes_#{i}_email').value = 'buck@hotmail.com'")
      end
      # Send individual characters one at a time to trigger autocomplete
      # Ref: https://github.com/teampoltergeist/poltergeist/issues/439#issuecomment-66871147
      find("#submission_committee_members_attributes_1_name").native.send_keys(*"alex".chars)
    end

    it "allows me to autocomplete that committee member's information from LDAP" do
      dropdown_item_for_alex.click
      click_button 'Save and Input Program Head/Chair' if current_partner.graduate?
      click_button 'Save and Continue Editing' unless current_partner.graduate?
      visit author_submission_committee_members_path(submission)
      expect(page).to have_content "ajk5603@psu.edu"
    end
  end

  describe 'tooltips', honors: true, milsch: true do
    let!(:committee) { create_committee(submission) }

    it 'has tooltip for required committee members' do
      tooltips = find_all('.fa-exclamation-circle')
      expect(tooltips.count).to eq(submission.required_committee_roles.count)
      tooltips.first.hover
      expect(page).to have_css('.tooltip')
    end

    it 'has tooltip for added committee members' do
      click_on 'Add Committee Member'
      sleep 1
      tooltips = find_all('.fa-exclamation-circle')
      tooltips.last.hover
      expect(page).to have_css('.tooltip')
    end
  end

  describe 'email form checkbox' do
    let!(:committee) { create_committee(submission) }

    it 'toggles email form box readonly/writable', milsch: true do
      skip 'Non honors' if current_partner.honors?

      checkboxes = find_all('#email_form_release_switch')
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_0_email' and @readonly='readonly']") if current_partner.milsch?
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_1_email' and @readonly='readonly']") if current_partner.graduate?
      checkboxes.first.click
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_0_email']") if current_partner.milsch?
      expect(page).not_to have_xpath("//input[@id='submission_committee_members_attributes_0_email' and @readonly='readonly']") if current_partner.milsch?
      expect(page).to have_xpath("//input[@id='submission_committee_members_attributes_1_email']") if current_partner.graduate?
      expect(page).not_to have_xpath("//input[@id='submission_committee_members_attributes_1_email' and @readonly='readonly']") if current_partner.graduate?
    end
  end
end
