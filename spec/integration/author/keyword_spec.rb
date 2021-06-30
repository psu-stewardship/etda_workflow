RSpec.describe 'Tagit-keywords', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  context 'keyword tagit' do
    before do
      oidc_authorize_author
    end

    let(:submission) { FactoryBot.create :submission, :collecting_final_submission_files, author: current_author }
    let(:submission2) { FactoryBot.create :submission, :collecting_final_submission_files, author: current_author }
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, degree_type: degree.degree_type, head_of_program_is_approving: false }

    it 'allows author to delete keywords' do
      visit author_submission_edit_final_submission_path(submission)
      keyword_list1 = page.find('span.tagit-label').text
      number_of_keywords = page.all('ul.tagit li span.tagit-label').count
      expect(page).not_to have_content('Are you sure you want to delete keyword "' + keyword_list1[0] + '"?')
      keyword = page.find('.tagit-label').text
      page.find('.tagit-close').click
      expect(page).to have_content('Are you sure you want to delete keyword "' + keyword + '"?')
      page.find("#ConfirmModal button#delete").click
      expect(page).to have_selector('ul.tagit li span.tagit-label', count: number_of_keywords - 1)
    end

    it 'allows author to enter keywords that contain a blank' do
      visit author_submission_edit_final_submission_path(submission)
      page.find("li.tagit-new input").set('stuff and more stuff,')
      expect(page).to have_content('stuff and more stuff')
    end

    it 'allows author to cancel a keyword delete', js: true do
      visit author_submission_edit_final_submission_path(submission)
      keyword = page.find('.tagit-label').text
      page.find('.tagit-close').click
      expect(page).to have_content('Are you sure you want to delete keyword "' + keyword + '"?')
      page.find('button#cancel').click
      expect(page).to have_content(keyword)
    end

    it 'allows author to add more than one keyword', js: true do
      visit author_submission_edit_final_submission_path(submission)
      number_of_keywords = page.all('ul.tagit li span.tagit-label').count
      page.find("li.tagit-new input").set('add another keyword,')
      page.find("li.tagit-new input").set('and one more,')
      expect(page).to have_selector('ul.tagit li span.tagit-label', count: number_of_keywords + 2)
    end

    it 'allows a new keyword to be deleted via the confirmation modal', js: true do
      submission2.keywords = []
      new_keyword = 'a newkeyword'
      visit author_submission_edit_final_submission_path(submission2)
      page.find("li.tagit-new input").set(new_keyword + ',')
      expect(page).to have_content(new_keyword)
      page.find('a.tagit-close').click
      expect(page).to have_content('Are you sure you want to delete keyword "' + new_keyword + '"?')
    end
  end
end
