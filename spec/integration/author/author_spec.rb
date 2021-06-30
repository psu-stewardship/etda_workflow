RSpec.describe 'Author submission page', type: :integration, milsch: true, honors: true, js: true do
  require 'integration/integration_spec_helper'

  before do
    oidc_authorize_author
    visit author_submissions_path
  end

  let!(:author) { @current_author }

  context 'Author Submissions Page' do
    it 'displays a paragraph of thesis instructions' do
      expect(page).to have_content('You will need to input your committee, upload your format ')
      expect(page).to have_link('Accessibility')
    end
    it 'contains a list of submissions' do
      expect(page).to have_content('My Submissions')
      expect(page).to have_link('Start a new Submission') unless current_partner.graduate?
    end
  end

  context 'Author submission display when author has no submissions' do
    it "displays 'no submissions message'" do
      expect(page).to have_content("You don't have any submissions")
      expect(page).not_to have_link('Start a new Submission') if current_partner.graduate?
      expect(page).to have_link('Start a new Submission') unless current_partner.graduate?
      expect(page).not_to have_link('Contact Support')
    end
  end

  context 'Author submission display when author has a submission that is released for publication but no other submissions' do
    it 'displays completed submission Button' do
      FactoryBot.create :submission, :released_for_publication, author: author
      visit author_submissions_path(author)
      expect(page).not_to have_content("You don't have any submissions yet.")
      expect(page).not_to have_content('Existing submission found. The status of your previously submitted document is listed below.')
      expect(page).to have_link('My Published Submissions')
      expect(page).to have_content('If you would like to start') unless current_partner.graduate?
    end
  end

  context 'Author submission display when author has one submission' do
    it "displays 'submission found'" do
      FactoryBot.create :submission, :collecting_committee, author: author
      visit author_submissions_path
      expect(page).to have_content('Existing submission found. The status of your previously submitted document is listed below:')
      expect(page).to have_link('Provide Committee')
      expect(page).to have_content('If you would like to start a new thesis') unless current_partner.graduate?
      if current_partner.honors?
        new_link = find_link('Start a new Submission')
        expect(new_link['outerHTML']).to match(/You already have a/)
      end
    end
  end

  context 'Author submission display when author has more than one submissions' do
    before do
      oidc_authorize_author
      FactoryBot.create_list :submission, 2, author: current_author
      visit author_submissions_path
    end

    it "displays 'submissions found'" do
      expect(page).to have_content('submissions found')
    end
  end

  context 'Author submission display when author is an admin', milsch: true, honors: true, sset: true do
    let!(:committee_role2) { FactoryBot.create :committee_role, is_program_head: true, degree_type: DegreeType.default }
    let!(:program1) { FactoryBot.create :program, name: 'Program (PHD)' }
    let!(:program2) { FactoryBot.create :program, name: 'Program (MS)' }
    let!(:program_chair1) { FactoryBot.create :program_chair, program: program1 }
    let!(:program_chair2) { FactoryBot.create :program_chair, program: program2 }
    let!(:degree2) { FactoryBot.create :degree, name: 'PHD', degree_type: DegreeType.default }

    context 'when current partner is graduate' do
      before do
        skip 'graduate only' unless current_partner.graduate?
      end

      let!(:degree1) { FactoryBot.create :degree, name: 'MS', degree_type: DegreeType.second }

      it 'displays buttons to create submissions' do
        FactoryBot.create :admin, access_id: 'authorflow'
        visit author_submissions_path
        expect(page).to have_link "Create Dissertation"
        expect(page).to have_link "Create Master's Thesis"
        expect { click_link "Create Master's Thesis" }.to change(Submission, :count).by 1
        expect(page).to have_content Submission.last.program.name
        expect(page).to have_link "Create Dissertation"
        expect(page).to have_link "Create Master's Thesis"
        expect(page).to have_link "[delete submission"
        expect { click_link "Create Dissertation" }.to change(Submission, :count).by 1
        expect(page).to have_content Submission.last.program.name
      end
    end

    context 'when current partner is not graduate' do
      before do
        skip 'nongraduate only' if current_partner.graduate?
      end

      it 'does not display create submission buttons' do
        FactoryBot.create :admin, access_id: 'authorflow'
        visit author_submissions_path
        expect(page).not_to have_link "Create Dissertation"
        expect(page).not_to have_link "Create Master's Thesis"
      end
    end
  end

  context 'Author submission display when author is not an admin' do
    it 'does not display create submission buttons' do
      skip 'graduate only' unless current_partner.graduate?

      visit author_submissions_path
      expect(page).not_to have_link "Create Dissertation"
      expect(page).not_to have_link "Create Master's Thesis"
    end
  end
end
