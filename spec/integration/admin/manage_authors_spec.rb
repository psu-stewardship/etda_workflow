RSpec.describe "Manage Authors", js: true do
  require 'integration/integration_spec_helper'

  let!(:degree) { FactoryBot.create :degree }
  let!(:author1) { FactoryBot.create :author }
  let!(:author2) { FactoryBot.create :author, confidential_hold: true }

  before do
    oidc_authorize_admin
    visit admin_authors_path
  end

  it 'has a list of authors' do
    submission1 = FactoryBot.create :submission, :waiting_for_final_submission_response,
                                    created_at: Time.zone.now,
                                    updated_at: (Time.zone.now - 2.years)
    submission2 = FactoryBot.create :submission, :released_for_publication,
                                    created_at: (Time.zone.now - 2.years),
                                    updated_at: (Time.zone.now - 2.years)
    author1.submissions = [submission1, submission2]
    allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).and_return(true)
    allow_any_instance_of(Author).to receive(:populate_with_ldap_attributes).and_return(true)
    expect(page).to have_current_path(admin_authors_path)
    expect(page).to have_content('Authors')
    expect(page).to have_content('Access ID')
    expect(page).to have_content('Last Name')
    expect(page).to have_content('First Name')
    expect(page).to have_content('Alternate Email')
    expect(page).to have_content('PSU Email')
    expect(page).to have_content(author1.access_id)
    expect(page).to have_content(author2.last_name)
    expect(page.find('span.fa.fa-warning')).to be_truthy
    expect(page).to have_content(author1.first_name)
    expect(page).to have_content(author2.alternate_email_address)
    expect(page).to have_content(author1.psu_email_address)
    click_link(author1.access_id.to_s)
    expect(page).to have_button('Update Author')
    expect(page).to have_current_path(edit_admin_author_path(author1))
    expect(page).to have_content(author1.psu_idn)
    expect(page).to have_content(author1.access_id)
    expect(page).not_to have_content(author2.access_id)
    expect(page).to have_field('Last name', with: author1.last_name)
    expect(page).to have_field('First name', with: author1.first_name)
    expect(page).to have_content(author1.psu_email_address)
    expect(page).to have_content('Show Submissions')
    expect(page).to have_field('Address 1', with: author1.address_1)
    expect(page).to have_field('Phone number', with: author1.phone_number)
    expect(page).to have_field('Address 2', with: author1.address_2)
    expect(page).to have_field('City', with: author1.city)
    expect(page).to have_field('State', with: author1.state)
    expect(page).to have_field('Zip', with: author1.zip)
    expect(page).to have_field('Country', with: author1.country)
    expect(page).to have_field('Alternate email address', with: author1.alternate_email_address)
    expect(page).to have_field('Display your alternate email address on your eTD document summary page?') if current_partner.graduate?
    page.find('div.form-section-heading').click
    expect(page).to have_link(submission1.title.to_s)
    expect(page).to have_content('released for publication')
    expect(page).to have_link(submission2.title.to_s)
    expect(page).not_to have_content('Confidential Hold')
    expect(page).to have_content(Time.zone.now.strftime('%m/%d/%Y'))
    expect(page).to have_link('Cancel')
    fill_in('First name', with: 'correctname')
    click_button('Update Author')
    # expect(page).to have_content('Author successfully updated')
    author1.reload
    expect(author1.admin_edited_at).to be_truthy
    expect(submission1.updated_at.year).to eq DateTime.now.year
    expect(submission2.updated_at.year).to eq DateTime.now.year
    visit edit_admin_author_path(author1)
    expect(page).to have_field('First name', with: 'correctname')
    click_link('Cancel')
    expect(page).to have_content('Authors')
    expect(page).to have_content('Showing')
    expect(page).to have_content('PSU Email')
    expect(page).to have_current_path(admin_authors_path)
    expect(page).to have_content('correctname')
    # expect(page).to have_link('Contact Support')
    expect(page).to have_link('Accessibility')
  end
end
