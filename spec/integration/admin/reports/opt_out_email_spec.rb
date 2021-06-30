RSpec.describe "Opt out Report", js: true do
  require 'integration/integration_spec_helper'
  describe 'it creates an array of authors with published submissions', js: true do
    let(:author1) { FactoryBot.create :author }
    let(:author2) { FactoryBot.create :author }
    let(:author3) { FactoryBot.create :author }
    let(:author4) { FactoryBot.create :author }

    if current_partner.graduate?
      it 'displays a list of authors with published submissions' do
        oidc_authorize_admin
        FactoryBot.create :submission, :final_is_restricted, author: author1
        FactoryBot.create :submission, :final_is_restricted_to_institution, author: author2
        FactoryBot.create :submission, status: 'released for publication', author: author3
        FactoryBot.create :submission, status: 'collecting format review files', author: author4
        visit 'admin/authors/contact_list'
        expect(page).to have_content('Email Contact List')
        expect(page).to have_link(author1.last_name)
        expect(page).not_to have_link(author4.last_name)
        expect(page).to have_content('Showing 1 to 3 of 3 entries')
      end
    end
  end
end
