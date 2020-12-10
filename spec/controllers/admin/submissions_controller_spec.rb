# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubmissionsController, type: :controller do
  before do
    # Need to authenticate as an admin for these controller specs to work
    # this is now 
    headers = { 'REMOTE_USER' => 'xxb13', 'REQUEST_URI' => '/admin/degrees' }
    request.headers.merge! headers
    # Devise::Strategies::WebaccessAuthenticatable.new(headers).authenticate!
  end

  describe '#redirect_to_default_dashboard' do
    it 'redirects to default dashboard' do
      expect(get: admin_root_path).to route_to(controller: 'admin/submissions', action: 'redirect_to_default_dashboard')
    end
  end

  describe '#dashboard' do
    it 'displays dashboard index and resets session semester' do
      session["semester"] = 'All Semesters'
      expect(get: admin_submissions_dashboard_path(DegreeType.default)).to route_to(controller: 'admin/submissions', action: 'dashboard', 'degree_type': DegreeType.default.slug)
      get :dashboard, params: { degree_type: DegreeType.default.slug }
      expect(response).to render_template('admin/submissions/dashboard')
      expect(session["semester"]).to eq nil
    end
  end

  describe '#edit' do
    it 'edits a submission' do
      submission = FactoryBot.create :submission, :released_for_publication
      expect(get: admin_edit_submission_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'edit', 'id': submission.id.to_s)
      get :edit, params: { id: submission.id.to_s }
      expect(response).to render_template('admin/submissions/edit')
    end
  end

  describe '#update' do
    it 'updates a submission' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      create_committee(submission)
      expect(patch: admin_submission_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'update', 'id': submission.id.to_s)
      patch :edit, params: { id: submission.id.to_s, submission: submission.attributes }
      expect(response).to render_template('admin/submissions/edit')
    end
  end

  describe '#index' do
    it 'displays a submissions index page for format_review_submitted filter' do
      scope = 'format_review_is_submitted'
      expect(get: admin_submissions_index_path(DegreeType.default.slug, scope)).to route_to(controller: 'admin/submissions', action: 'index', degree_type: DegreeType.default.slug, scope: 'format_review_is_submitted')
      get :index, params: { degree_type: DegreeType.default.slug, scope: 'format_review_submitted' }
      expect(response).to render_template('admin/submissions/index')
    end
    it 'displays a submissions index page for final submissions submitted filter' do
      scope = 'final_submission_is_submitted'
      expect(get: admin_submissions_index_path(DegreeType.default.slug, scope)).to route_to(controller: 'admin/submissions', action: 'index', degree_type: DegreeType.default.slug, scope: 'final_submission_is_submitted')
      get :index, params: { degree_type: DegreeType.default.slug, scope: 'final_submission_submitted' }
      expect(response).to render_template('admin/submissions/index')
    end
  end

  describe '#bulk_destroy' do
    it 'deletes a group of submissions' do
      expect(delete: admin_delete_submissions_path).to route_to(controller: 'admin/submissions', action: 'bulk_destroy')
    end
  end

  describe '#release for publication' do
    it 'releases a group of submissions' do
      expect(patch: admin_submissions_release_final_submission_approved_path(DegreeType.default.id)).to route_to(controller: 'admin/submissions', action: 'release_for_publication', degree_type: DegreeType.default.id.to_s)
      get :index, params: { degree_type: DegreeType.default.slug, scope: 'released_for_publication' }
      expect(response).to render_template('admin/submissions/index')
    end
  end

  describe '#extend_publication_date' do
    it 'extends the publication date of withheld or restricted submissions' do
      expect(patch: admin_submissions_extend_publication_date_path(DegreeType.default.id)).to route_to(controller: 'admin/submissions', action: 'extend_publication_date', degree_type: DegreeType.default.id.to_s)
      submission1 = FactoryBot.create :submission, :final_is_restricted
      submission2 = FactoryBot.create :submission, :final_is_restricted
      patch :extend_publication_date, params: { submission_ids: "#{submission1.id}, #{submission2.id}", date_to_release: Date.today.strftime('%m/%d/%Y'), degree_type: DegreeType.default.slug }
      expect(response.status).to be(204)
    end
  end

  describe '#record_format_review_response' do
    it 'processes the admins response to a format review that was submitted' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      expect(patch: admin_submissions_format_review_response_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'record_format_review_response', id: submission.id.to_s)
      get :record_format_review_response, params: { id: submission.id, submission: submission.attributes, reject: true }
      expect(response.status).to be(302)
      expect(response).to redirect_to("/admin/#{DegreeType.default.slug}/format_review_submitted")
    end
  end

  describe '#waiting_for_final_submission_response' do
    submission = FactoryBot.create :submission, :waiting_for_final_submission_response
    it 'processes the admin users\'s response to a final submission that was submitted' do
      expect(patch: admin_submissions_final_submission_response_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'record_final_submission_response', id: submission.id.to_s)
    end
  end

  describe '#update_waiting_to_be_released' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    it 'releases a submission' do
      expect(patch: admin_submissions_update_waiting_to_be_released_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'update_waiting_to_be_released', id: submission.id.to_s)
    end
  end

  describe '#print_signatory_page' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'displays the signatory page' do
      expect(get: admin_submission_print_signatory_page_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'print_signatory_page', id: submission.id.to_s)
    end
  end

  describe '#print_signatory_page_update' do
    it 'updates \'is_printed?\' attribute' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      expect(patch: admin_submissions_print_signatory_page_update_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'print_signatory_page_update', id: submission.id.to_s)
      patch :print_signatory_page_update, params: { id: submission.id.to_s }
      expect(response.status).to be(302)
      expect(response).to redirect_to("/admin/#{DegreeType.default.slug}/format_review_submitted")
    end
  end

  describe '#refresh_committee' do
    it 'refreshes committee information with information from Lion Path' do
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response
      expect(get: admin_refresh_committee_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'refresh_committee', id: submission.id.to_s)
      expect(response.status).to eq(200) if InboundLionPathRecord.active?
    end
  end

  describe '#refresh_academic_plan' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'refreshes academic plan with information from Lion Path' do
      expect(get: admin_submissions_refresh_academic_plan_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'refresh_academic_plan', id: submission.id.to_s)
      expect(response.status).to eq(200) if InboundLionPathRecord.active?
    end
  end

  describe 'raising errors' do
    it 'raises RecordInvalid' do
      expect { get :edit, params: { id: 0 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
