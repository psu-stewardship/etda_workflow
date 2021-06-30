# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
  before do
    # Skip authentication
    allow_any_instance_of(AdminController).to receive(:set_session).and_return true
    allow_any_instance_of(AdminController).to receive(:admin_auth).and_return true
  end

  describe '#custom_reports_index' do
    it 'displays custom report' do
      expect(get: admin_custom_report_index_path).to route_to(controller: 'admin/reports', action: 'custom_report_index')
    end
  end

  describe '#custom_report_export' do
    it 'exports the custom report information in CSV format' do
      expect(patch: admin_custom_report_export_path).to route_to(controller: 'admin/reports', action: 'custom_report_export', format: 'csv')
      patch :custom_report_export, params: { submission_ids: '1,2', format: "csv" }
      expect(response.headers["Content-Disposition"]).to eq 'attachment; filename="custom_report.csv"'
    end
  end

  describe '#final_submission_approved' do
    it 'exports final submissions that have been approved in CSV format' do
      expect(patch: admin_export_final_submission_approved_path(DegreeType.default.slug)).to route_to(controller: 'admin/reports', action: 'final_submission_approved', degree_type: DegreeType.default.slug)
      patch :final_submission_approved, params: { submission_ids: '1,2', format: "csv", degree_type: DegreeType.default.slug }
      expect(response.headers["Content-Disposition"]).to eq 'attachment; filename="final_submission_report.csv"'
    end
  end

  describe '#confidential_hold_report_index' do
    it 'displays confidential hold report' do
      expect(get: admin_confidential_hold_report_index_path).to route_to(controller: 'admin/reports', action: 'confidential_hold_report_index')
    end
  end

  describe '#confidential_hold_report_export' do
    it 'exports the confidential hold report information in CSV format' do
      expect(patch: admin_confidential_hold_report_export_path).to route_to(controller: 'admin/reports', action: 'confidential_hold_report_export', format: 'csv')
      patch :confidential_hold_report_export, params: { author_ids: '1,2', format: "csv" }
      expect(response.headers["Content-Disposition"]).to eq 'attachment; filename="confidential_hold_report.csv"'
    end
  end
end
