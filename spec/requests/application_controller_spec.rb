# frozen_string_literal: true

require 'rails_helper'
require 'devise/test/controller_helpers'

RSpec.describe 'Devise Login', type: :request do
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
  let(:author) { FactoryBot.create(:author) }

  before do
    allow(request).to receive(:controller).and_return("admin/degrees")
    allow(request).to receive(:headers).and_return('REMOTE_USER' => 'saw140')
    # allow(Rails.application.secrets).to receive(:webaccess).and_return(vservice: "ahost.psu.edu", vhost: 'https://myapp.psu.edu')
  end

  it 'signs author in and out' do
    headers = { 'REMOTE_USER' => 'ajk5603', 'REQUEST_URI' => '/author/submissions' }
    expect(Author.find_by(access_id: 'ajk5603')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::WebaccessAuthenticatable.new(headers).authenticate!
    get root_path
    expect(Author.find_by(access_id: 'ajk5603')).not_to be_nil
  end

  it 'signs admin in and out' do
    headers = { 'REMOTE_USER' => 'xxb13', 'REQUEST_URI' => '/admin/degrees' }
    expect(Admin.find_by(access_id: 'xxb13')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::WebaccessAuthenticatable.new(headers).authenticate!
    get root_path
    expect(Admin.find_by(access_id: 'xxb13')).not_to be_nil
  end

  it 'does not authenticate an admin who is not in ldap admin group' do
    headers = { 'REMOTE_USER' => 'saw140', 'REQUEST_URI' => '/admin/degrees' }
    expect(Admin.find_by(access_id: 'saw140')).to be_nil
    request.headers.merge! headers
    Devise::Strategies::WebaccessAuthenticatable.new(headers).authenticate! if LdapUniversityDirectory.new.in_admin_group? 'saw140'
    expect(Admin.find_by(access_id: 'saw140')).to be_nil
  end

  context 'production environment' do
    before do
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    xit 'author can login and logout' do
      get login_path
      assert_response :redirect, "<302: Found> redirect to <#{WebAccess.new.login_url}>"

      get logout_path
      assert_response :redirect, "<302: Found> redirect to <#{WebAccess.new.logout_url}>"
    end
  end

  context 'development environment' do
    before do
      allow(Rails).to receive(:env) { "production".inquiry }
    end

    xit 'author can login and logout' do
      get login_path
      assert_response :redirect, "<302: Found> redirect to <#{WebAccess.new.login_url}>"

      get logout_path
      assert_response :redirect, "<302: Found> redirect to <#{WebAccess.new.logout_url}>"
    end
  end
end
