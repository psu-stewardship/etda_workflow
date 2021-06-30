# frozen_string_literal: true

RSpec.describe "Manage Programs", js: true do
  require 'integration/integration_spec_helper'

  let!(:program) { FactoryBot.create :program }
  let!(:program2) { FactoryBot.create :program }

  before do
    oidc_authorize_admin
    visit admin_programs_path
  end

  it 'has a list of programs' do
    expect(page).to have_content(program.name)
    expect(page).to have_content(program.code)
    expect(page).to have_content(program2.name)
    expect(page).to have_content(program2.code)
    page.find('.add-button').click
    expect(page).to have_button("Create #{current_partner.program_label}")
    fill_in 'Name', with: 'A New Program'
    find('#program_is_active_true').click
    button_text = "Create #{current_partner.program_label}"
    click_button button_text
    expect(page).to have_current_path(admin_programs_path)
    expect(page).to have_content(program.name)
    within('tr', text: 'A New Program') do
      expect(page).to have_content('A New Program')
      expect(page).to have_content('Yes')
    end
    # expect(page).to have_content("#{current_partner.program_label} successfully created")
    click_link 'A New Program'
    expect(page).to have_content("Edit A New Program")
    find('#program_is_active_false').click
    click_button "Update #{current_partner.program_label}"
    expect(page).to have_content(program.name)
    within('tr', text: 'A New Program') do
      expect(page).to have_content('No')
    end
    # expect(page).to have_content("#{current_partner.program_label} successfully updated")
    fill_in 'Search records...', with: 'A New'
    expect(page).to have_content('A New Program')
    expect(page).not_to have_content(program.name)
    expect(page).not_to have_content(program2.name)
    status_str = printf('Showing 1 to %1d of %1d records', Program.all.count, Program.all.count)
    expect(page).to have_content(status_str)
    fill_in 'Search records...', with: 'different program'
    expect(page).to have_content('No matching records found')
    expect(page).to have_link('Accessibility')
  end
end
