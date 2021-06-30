RSpec.describe "Release a submission with a public id", js: true, honors: true, milsch: true do
  require 'integration/integration_spec_helper'

  let(:degree_type) { current_partner.graduate? ? 'dissertation' : 'thesis' }
  let!(:program) { FactoryBot.create(:program, name: "Any Program", is_active: true) }
  let!(:degree) { FactoryBot.create(:degree, name: DegreeType.default.slug, is_active: true) }
  let!(:role) { CommitteeRole.first.name }
  let(:submission) { FactoryBot.create(:submission, :waiting_for_publication_release, access_level: 'open_access') }

  let(:jane_author)  { FactoryBot.create :author }
  let(:joe_author)   { FactoryBot.create :author }
  let(:submission_1) { FactoryBot.create(:submission, :waiting_for_final_submission_response, author: joe_author) }
  let(:submission_2) { FactoryBot.create(:submission, :waiting_for_final_submission_response, author: jane_author) }
  let(:submission_3) { FactoryBot.create(:submission, :waiting_for_final_submission_response, author: jane_author) }

  before do
    oidc_authorize_admin
  end

  it 'assigns a public id and releases a submission', js: true do
    allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
    expect(submission.legacy_id).to be_blank
    expect(submission.public_id).to be_blank
    released_count = Submission.released_for_publication.count
    visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
    click_button 'Select Visible'
    sleep 1
    expect(page).to have_content('Showing')
    page.accept_confirm do
      click_button 'Release selected for publication'
    end
    expect(page).to have_content('All submissions were successfully published')
    updated_released_count = Submission.released_for_publication.count
    expect(page).to have_content("1 submission successfully released for publication")
    expect(updated_released_count).to eql(released_count + 1)
    submission.reload
    expect(submission.public_id).to eql("#{submission.id}#{submission.author.access_id}")
  end

  it 'does not assign a public id that already exists and does not release a submission', js: true do
    allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
    expect(submission.legacy_id).to be_blank
    expect(submission.public_id).to be_blank
    submission_2.update_attribute(:public_id, "#{submission_1.id}#{submission_1.author.access_id}")
    submission_3.update_attribute(:public_id, "#{submission_1.id}#{submission_1.author.access_id}-#{submission_1.author.id}")
    submission.update_attribute(:status, 'waiting for final submission response')
    submission_1.update_attribute(:status, 'waiting for publication release')
    released_count = Submission.released_for_publication.count
    visit admin_submissions_index_path(DegreeType.default, 'final_submission_approved')
    click_button 'Select Visible'
    sleep 1
    expect(page).to have_content('Showing')
    page.accept_confirm do
      click_button 'Release selected for publication'
    end
    submission_1.reload
    expect(page).to have_content('No submissions successfully released for publication.')
    expect(page).to have_content("Error occurred processing submission id: #{submission_1.id}, #{submission_1.author.last_name}, #{submission_1.author.first_name}")
    expect(Submission.released_for_publication.count).to eql(released_count + 0)
    expect(submission_1.public_id).to be_nil
  end
end
