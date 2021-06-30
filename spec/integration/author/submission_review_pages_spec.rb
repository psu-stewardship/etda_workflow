RSpec.describe 'Author submission review pages', type: :integration, js: true do
  require 'integration/integration_spec_helper'

  let!(:submission1) { FactoryBot.create :submission, :waiting_for_publication_release, author: current_author }
  let!(:submission2) { FactoryBot.create :submission, :waiting_for_committee_review, author: current_author }
  let!(:approval_configuration1) { FactoryBot.create :approval_configuration, degree_type: submission1.degree_type }
  let!(:approval_configuration2) { FactoryBot.create :approval_configuration, degree_type: submission2.degree_type }
  let(:invention_disclosures) { FactoryBot.create(:invention_disclosure, submission) }
  let(:committee_member1) { FactoryBot.create :committee_member, submission: submission1 }
  let(:committee_member2) { FactoryBot.create :committee_member, submission: submission1 }
  let(:committee_member3) { FactoryBot.create :committee_member, submission: submission2 }
  let(:committee_member4) { FactoryBot.create :committee_member, submission: submission2 }
  let(:format_review_file) { FactoryBot.create :format_review_file, submission: submission1 }
  let(:final_submission_file) do
    FactoryBot.create :final_submission_file, submission: submission1
  end
  let(:long_note) do
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Amicitiam autem adhibendam esse censent, quia sit ex eo genere, quae prosunt. An vero, inquit, quisquam potest probare, quod perceptfum, quod. Hinc ceteri particulas arripere conati suam quisque videro voluit afferre sententiam. Illum mallem levares, quo optimum atque humanissimum virum, Cn. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Duo Reges: constructio interrete. Id enim volumus, id contendimus, ut officii fructus sit ipsum officium. Hoc ille tuus non vult omnibusque ex rebus voluptatem quasi mercedem exigit.
Haec para/doca illi, nos admirabilia dicamus. Nobis aliter videtur, recte secusne, postea; Verum tamen cum de rebus grandioribus dicas, ipsae res verba rapiunt; Non quaeritur autem quid naturae tuae consentaneum sit, sed quid disciplinae. Eorum enim est haec querela, qui sibi cari sunt seseque diligunt. Paulum, cum regem Persem captum adduceret, eodem flumine invectio? Quantum Aristoxeni ingenium consumptum videmus in musicis? Fortemne possumus dicere eundem illum Torquatum? At iste non dolendi status non vocatur voluptas. Atque hoc loco similitudines eas, quibus illi uti solent, dissimillimas proferebas. Quare attende, quaeso. Et nemo nimium beatus est; Quid enim est a Chrysippo praetermissum in Stoicis? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Amicitiam autem adhibendam esse censent, quia sit ex eo genere, quae prosunt. An vero, inquit, quisquam potest probare, quod perceptfum, quod. Hinc ceteri particulas arripere conati suam quisque videro voluit afferre sententiam. Illum mallem levares, quo optimum atque humanissimum virum, Cn. Ne amores quidem sanctos a sapiente alienos esse arbitrantur. Duo Reges: constructio interrete. Id enim volumus, id contendimus, ut officii fructus sit ipsum officium. Hoc ille tuus non vult omnibusque ex rebus voluptatem quasi mercedem exigit. Et nemo nimium beatus est; Quid enim est a Chrysippo praetermissum in Stoicis?'
  end

  before do
    submission1.committee_members << committee_member1
    submission1.committee_members << committee_member2
    submission1.access_level = 'restricted'
    submission1.invention_disclosure.id_number = '1234'
    submission1.restricted_notes = long_note
    submission1.format_review_files << format_review_file
    submission1.final_submission_files << final_submission_file
    submission1.save
    submission2.committee_members << committee_member3
    submission2.committee_members << committee_member4
    oidc_authorize_author
    visit author_submissions_path
  end

  context 'author can review program information' do
    it 'displays program information for the submission' do
      visit "/author/submissions/#{submission1.id}/program_information"
      expect(page).to have_content(submission1.title)
      page.find(:css, '#title.odd')
      expect(page).to have_content(current_partner.program_label)
      expect(page).to have_content('Semester Intending to Graduate')
      expect(page).to have_content(submission1.semester)
      expect(page).to have_content('Graduation Year')
      expect(page).to have_content(submission1.year)
      expect(page).to have_link('Return to dashboard')
    end
  end

  context 'author can review submission committee information' do
    it 'displays program information for the submission' do
      visit "/author/submissions/#{submission1.id}/committee_members"
      expect(page).to have_content('Committee Members')
      expect(page).to have_content('Name')
      expect(page).to have_content('Role')
      expect(page).to have_content('Email')
      expect(page.find(:css, 'table.table tbody').first('tr.odd')).to be_truthy
      expect(page).to have_content(submission1.committee_members[0].name)
      expect(page).to have_content(submission1.committee_members[1].name)
      expect(page).to have_content(submission1.committee_members[0].committee_role.name)
      expect(page).to have_link('Return to dashboard')
    end
  end

  context 'author can review format review information' do
    it 'displays format review information for the submission in a new browser tab' do
      allow(format_review_file).to receive(:current_location).and_return('spec/fixtures/format_review_file_01.pdf')
      visit "/author/submissions/#{submission1.id}/format_review"
      expect(page).to have_content('Format Review Files')
      expect(page).to have_content(submission1.title)
      expect(page).to have_content(submission1.format_review_files.first.asset.identifier)
      expect(page).to have_link('Return to dashboard')
      format_file_id = "format-review-file-#{submission1.format_review_files.first.id}"
      format_div = "div#" + format_file_id
      format_review_section = page.find(format_div)
      num_windows = page.driver.browser.window_handles.count
      within(format_review_section) do
        format_link = page.find("a.file-link")
        format_link.click
      end
      sleep 0.1
      expect(page.driver.browser.window_handles.count).to eql(num_windows + 1)
    end
  end

  context 'author can review final submission information in a new browser tab' do
    it 'displays final submission information' do
      allow(final_submission_file).to receive(:current_location).and_return('spec/fixtures/final_submission_file_01.pdf')
      visit "/author/submissions/#{submission1.id}/final_submission"
      expect(page).to have_content('Final Submission Files')
      expect(page).to have_content(submission1.title)
      expect(page).to have_content('Date defended') if current_partner.graduate?
      expect(page).to have_content('Keywords')
      expect(page).to have_content(submission1.keywords.first.word)
      expect(page).to have_content('Access level')
      expect(page).to have_content(submission1.current_access_level.label)
      expect(page).to have_content(submission1.final_submission_files.first.asset.identifier)
      expect(page).to have_content(submission1.invention_disclosures.first.id_number)
      expect(page).to have_content(submission1.abstract)
      expect(page).to have_content("Lorem ipsum dolor sit amet")
      expect(page).to have_link('Return to dashboard')
      final_file_id = "final-submission-file-#{submission1.final_submission_files.first.id}"
      final_div = "div#" + final_file_id
      final_submission_section = page.find(final_div)
      num_windows = page.driver.browser.window_handles.count
      within(final_submission_section) do
        final_link = page.find("a.file-link")
        final_link.click
      end
      sleep 0.1
      expect(page.driver.browser.window_handles.count).to eql(num_windows + 1)
    end
  end

  context 'author can review committee member review information' do
    before do
      ActionMailer::Base.deliveries = []
    end

    context 'while waiting for committee review' do
      it 'has content' do
        visit "/author/submissions/#{submission2.id}/committee_review"
        within('table#committee_member_table') do
          expect(page).to have_content('Name')
          expect(page).to have_content('Status')
          expect(page).to have_content('Notes')
          expect(page).to have_content('Action')
          expect(page).to have_button('Send Email Reminder')
        end
      end

      context 'when committee member does not have a token' do
        it 'sends email reminder', honors: true, milsch: true do
          visit "/author/submissions/#{submission2.id}/committee_review"
          expect { find('table#committee_member_table').first(:button, "Send Email Reminder").click }.to(change { CommitteeMember.find(committee_member3.id).last_reminder_at })
          expect(page).to have_current_path(author_submission_committee_review_path(submission2.id))
          # expect(page).to have_content("Email successfully sent.")
          expect(WorkflowMailer.deliveries.first.to).to eq [committee_member3.email]
          expect(WorkflowMailer.deliveries.first.from).to eq [current_partner.email_address]
          expect(WorkflowMailer.deliveries.first.subject).to eq "Honors #{submission2.degree_type} Needs Approval" if current_partner.honors?
          expect(WorkflowMailer.deliveries.first.subject).to eq "#{submission2.degree_type} Needs Approval" if current_partner.graduate?
          expect(WorkflowMailer.deliveries.first.subject).to eq "Millennium Scholars #{submission2.degree_type} Review" if current_partner.milsch?
          expect(WorkflowMailer.deliveries.first.body).to match(/Reminder:/)
          expect { find('table#committee_member_table').first(:button, "Send Email Reminder").click }.not_to(change { CommitteeMember.find(committee_member3.id).last_reminder_at })
          expect(page).to have_current_path(author_submission_committee_review_path(submission2.id))
          # expect(page).to have_content("Email was not sent.")
          expect(WorkflowMailer.deliveries.count).to eq 1
        end
      end

      context 'when committee member does have a token' do
        it 'sends email reminder' do
          skip 'Graduate Only' unless current_partner.graduate?

          FactoryBot.create :committee_member_token, committee_member_id: committee_member3.id
          visit "/author/submissions/#{submission2.id}/committee_review"
          find('table#committee_member_table').first(:button, "Send Email Reminder").click
          expect(WorkflowMailer.deliveries.first.to).to eq [committee_member3.email]
          expect(WorkflowMailer.deliveries.first.from).to eq [current_partner.email_address]
          expect(WorkflowMailer.deliveries.count).to eq 1
          expect(WorkflowMailer.deliveries.first.body).to match(/\/special_committee\//)
        end
      end
    end

    context 'while waiting for publication release' do
      it 'has disabled send email button' do
        visit "/author/submissions/#{submission1.id}/committee_review"
        within('table#committee_member_table') do
          expect(page).to have_content('Name')
          expect(page).to have_content('Status')
          expect(page).to have_content('Notes')
          expect(page).not_to have_content('Action')
          expect(page).not_to have_button('Send Email Reminder')
        end
      end
    end
  end
end
