# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApproverController, type: :controller do
  before do
    @approver_controller = ApproverController.new
    allow(@approver_controller).to receive(:request).and_return(request)
    allow(@approver_controller).to receive(:valid_approver_session?).and_return(true)
  end

  describe @author_controller do
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'approverflow', 'REQUEST_URI' => 'approver/reviews' }) }

    it 'returns 200 response' do
      allow(request).to receive(:env).and_return(:headers)
      expect(response.status).to eq(200)
    end
  end

  # describe 'private' do
  #   let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'authorflow', 'REQUEST_URI' => '/' }) }
  #   it 'executes a private method' do
  #     allow(request).to receive(:env).and_return(:headers)
  #
  #     expect(@author_controller.send(:find_or_initialize_author)).to render_template('author/index')
  #   end
  # end
end