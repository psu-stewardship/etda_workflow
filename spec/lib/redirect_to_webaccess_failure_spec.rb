# frozen_string_literal: true

require 'rails_helper'
require 'devise'

RSpec.describe RedirectToWebaccessFailure, type: :model do
  subject = described_class.new
  before { allow(subject).to receive(:request).and_return(request) }

  describe subject do
    let(:request) { double(headers: { 'HTTP_REMOTE_USER' => 'me123', 'REQUEST_URI' => '/' }) }

    xit 'creates redirect url' do
      allow(request).to receive(:env).and_return(:headers)
      expect(subject.redirect_url).to eq(WebAccess.new.login_url)
    end

    # it 'responds' do
    #   allow_any_instance_of(Devise::FailureApp).to receive(:send).with('http_auth?').and_return(false)
    #   allow(request).to receive(:xhr?).with(null_object).and_return(false)
    #   expect(subject.respond.first).to eq(301)
    # end
  end
end
