RSpec.describe "Admins can run reports", js: true do
  require 'integration/integration_spec_helper'

  submission_year = Semester.current.split[0]
  submission_semester = Semester.current.split[1]
  # let(:admin) { FactoryBot.create :admin }
  let(:degree_type) { FactoryBot.create :degree_type, name: 'Dissertation', slug: 'dissertation' }
  let!(:author1) { FactoryBot.create :author, access_id: 'xyz321', psu_email_address: 'xyz321@psu.edu', first_name: 'Author', last_name: 'One' }
  let!(:author2) { FactoryBot.create :author, access_id: 'abc987', psu_email_address: 'abc987@psu.edu', first_name: 'Author', last_name: 'Two' }
  let!(:author3) { FactoryBot.create :author, access_id: 'abc123', psu_email_address: 'abc123@psu.edu', first_name: 'Author', last_name: 'Three', confidential_hold: 1, confidential_hold_set_at: DateTime.now }
  # let(:degree) { Degree.first }
  let!(:degree) { FactoryBot.create :degree, degree_type_id: DegreeType.default.id, name: 'PHD', description: 'PHD', is_active: true }
  let!(:submission1) { FactoryBot.create :submission, :released_for_publication, author: author1, year: submission_year, semester: submission_semester, title: 'Submission1', degree_id: degree.id, access_level: 'open_access' }
  let!(:submission2) { FactoryBot.create :submission, :released_for_publication, author: author2, year: submission_year, semester: submission_semester, title: 'Submission2', degree_id: degree.id, access_level: 'restricted' }
  let!(:submission3) { FactoryBot.create :submission, :waiting_for_format_review_response, author: author2, year: submission_year, semester: submission_semester, title: 'Submission3' }
  let(:invention_number) { "#{submission_year}-1234" }

  before do
    create_committee(submission1)
    create_committee(submission2)
    # submission1.save!
    submission2.invention_disclosures << InventionDisclosure.new(id_number: invention_number)
    submission2.access_level = 'restricted'
    # submission2.save!
    oidc_authorize_admin
    visit admin_submissions_dashboard_path(Degree.first.degree_type)
  end

  context('Report link is visible on left navigation') do
    it 'contains a report link on the main navigation' do
      expect(page).to have_link('Reports')
      expect(page).not_to have_link('Committee Report')
    end
  end

  context 'clicking on Report link', js: true do
    it 'displays the available report types' do
      expect(page).to have_link('Reports')
      page.find('a#reports_menu').click
      expect(page).to have_link('Custom Report')
      expect(page).to have_link('Confidential Hold Report')
    end
  end

  context 'custom report page' do
    before do
      submission2.access_level = 'restricted'
      submission2.save
      visit admin_submissions_dashboard_path(DegreeType.first)
      click_link('Reports')
    end

    it 'displays the invention disclosure number and access level' do
      expect(page).to have_link('Custom Report')
      click_link('Custom Report')
      expect(page).to have_content(invention_number) if current_partner.graduate?
      expect(page).to have_content('Restricted')
    end

    it 'displays the Custom Report page' do
      instance_spy('Admin::ReportsController')
      expect(page).to have_link('Custom Report')
      click_link('Custom Report')
      expect(page).to have_content('Custom Report')
      expect(page).to have_button('Select Visible')
      expect(page).to have_content('Submission3')
      expect(page).to have_content(submission2.program.name)
      click_button 'Select Visible'
      page.assert_selector('tbody .row-checkbox')
      ckbox = all('tbody .row-checkbox')
      assert_equal(Submission.where(year: submission_year, semester: submission_semester).count, ckbox.count)
      ckbox.each do |cb|
        expect(have_checked_field(cb)).to be_truthy
      end
      expect(page).to have_button('Export CSV')
      click_button('Export CSV')
    end
  end

  context 'final_submission_approved' do
    before do
      submission1.status = 'waiting for publication release'
      submission2.status = 'waiting for publication release'
      submission1.save
      submission2.save
      visit(admin_submissions_index_path(DegreeType.default, 'final_submission_approved'))
      sleep 1
    end

    it 'displays the final submissions' do
      expect(page).to have_content('Final Submission to be Released')
      click_button('Select Visible')
      expect(page).to have_button('Export CSV')
      click_button 'Export CSV'
    end
  end

  context 'confidential hold report index' do
    before do
      author3.submissions << submission1
      visit admin_submissions_dashboard_path(DegreeType.first)
      click_link('Reports')
      click_link('Confidential Hold Report')
    end

    it 'displays the confidential hold report' do
      expect(page).to have_content('Confidential Hold Report')
      expect(page).to have_content(author3.psu_email_address)
      click_button('Select Visible')
      expect(page).to have_button('Export CSV')
      click_button 'Export CSV'
    end

    it "links to author's page" do
      click_link author3.access_id
      expect(page).to have_current_path(edit_admin_author_path(author3))
    end
  end
end
