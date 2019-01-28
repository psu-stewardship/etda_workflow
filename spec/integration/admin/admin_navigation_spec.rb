RSpec.describe "Admin Navigation", js: true do
  require 'integration/integration_spec_helper'

  before do
    webaccess_authorize_admin
    visit '/admin'
    puts page.body
  end

  let(:admin) { current_admin}

  it 'has top navigation' do
    sleep 3
    expect(page).to have_link('Home')
    expect(page).to have_link('About')
    expect(page).not_to have_link('Contact Us')
    expect(page).to have_link('Explore')
    expect(page).to have_link('Log Out')
  end

  it 'has an about page' do
    click_link 'About'
    expect(page).to have_link('Thesis and Dissertation Guide') if current_partner.graduate?
    expect(page).to have_link('Thesis Guide') unless current_partner.graduate?
    expect(page).to have_content(current_partner.slug.to_s)
    expect(page).to have_content('Important Things')
    expect(page).to have_content('Expand Creative Possibilities')
  end

  it 'has a home page' do
    click_link 'Home'
    expect(page).to have_link('Home')
    expect(page).to have_link('About')
    expect(page).to have_link('Explore')
    expect(page).to have_link('Log Out')
    expect(page).to have_link('Create/Edit Submission')
    expect(page).to have_link('Admin')
  end
end