# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'
require 'support/request_spec_helper'

RSpec.describe Author, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:alternate_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:psu_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:phone_number).of_type(:string) }
  it { is_expected.to have_db_column(:address_1).of_type(:string) }
  it { is_expected.to have_db_column(:address_2).of_type(:string) }
  it { is_expected.to have_db_column(:city).of_type(:string) }
  it { is_expected.to have_db_column(:state).of_type(:string) }
  it { is_expected.to have_db_column(:zip).of_type(:string) }
  it { is_expected.to have_db_column(:is_alternate_email_public).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:confidential_hold).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_admin).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_site_admin).of_type(:boolean) }

  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:country).of_type(:string) }
  it { is_expected.to have_db_column(:psu_idn).of_type(:string) }

  it { is_expected.to validate_presence_of(:access_id) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:psu_email_address) }
  it { is_expected.to validate_presence_of(:alternate_email_address) }
  it { is_expected.to validate_presence_of(:psu_idn) }

  if EtdaUtilities::Partner.current.graduate?
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:address_1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip) }

    it 'only accepts correctly formatted email addresses' do
      expect(FactoryBot.build(:author, alternate_email_address: 'xyz-123@yahoo.com')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'someone@smith.ac.nz')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'abc123@cse.psu.edu')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'xyz-123 .com')).to_not be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'abc123@.psu.edu')).to_not be_valid
    end

    it 'only accepts correctly formatted psu_idn numbers' do
      expect(FactoryBot.build(:author, psu_idn: '912345678')).to be_valid
      expect(FactoryBot.build(:author, psu_idn: '901287085')).to be_valid
      expect(FactoryBot.build(:author, psu_idn: '91234567a')).to_not be_valid
      expect(FactoryBot.build(:author, psu_idn: '91234567.')).to_not be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456')).to_not be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456789')).to_not be_valid
      expect(FactoryBot.build(:author, psu_idn: '712345678')).to_not be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456-8')).to_not be_valid
    end
    it 'does not check format of phone number' do
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '123-xyz-7890')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '1234-567890')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '123456789')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '12345678901')).to be_valid
    end

    it 'expects correctly formatted zip code if one is entered for graduate authors' do
      author = FactoryBot.build(:author)
      author.zip = '078431=1234'
      expect(author).to_not be_valid
      author.zip = '07843-12345'
      expect(author).to_not be_valid
      author.zip = 'AB843-1234'
      expect(author).to_not be_valid
      author.zip = '12345-1234'
      expect(author).to be_valid
      author.zip = '12345'
      expect(author).to be_valid
      author.zip = '1234'
      expect(author).to_not be_valid
      author.zip = '12345-123'
      expect(author).to_not be_valid
      author.zip = '123456-12345'
      expect(author).to_not be_valid
    end
  end

  unless EtdaUtilities::Partner.current.graduate?
    context 'non graduate students are not expected to have contact address fields' do
      it { is_expected.not_to validate_inclusion_of(:state).in_array(UsStates.names.keys.map(&:to_s)) }
      it { is_expected.not_to validate_presence_of(:state) }
      it { is_expected.not_to validate_presence_of(:zip) }
      it { is_expected.not_to validate_presence_of(:address_1) }
      it { is_expected.not_to validate_presence_of(:phone_number) }
    end
  end

  it { is_expected.to have_db_index(:legacy_id) }

  context '#populate_attributes' do
  end

  context '#populate_with_ldap_attributes' do
    it 'populates the author record with ldap information' do
      expect(described_class.new.to_json).to eql(described_class.new.to_json)
      expect(described_class.new(access_id: 'xxb13').populate_with_ldap_attributes).to_not eql(described_class.new.to_json)
    end
  end

  context '#ldap_results_valid?' do
    it 'returns false if results are empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', nil)).to be_falsey
    end
    it 'returns false if access_ids do not match' do
      expect(described_class.new(access_id: 'wrongid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", is_admin: true, psu_idn: "999999999"))
    end
    it 'returns true if results are not empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", is_admin: true, psu_idn: "999999999")).to be_truthy
    end
  end

  context '#update_missing_attributes' do
    it 'populates PSU id number if it is not present' do
      author = described_class.new(access_id: 'testid')
      expect(author.psu_idn).to be_nil
      author.update_missing_attributes
      expect(author.psu_idn).not_to be_nil
    end
    it 'does not update PSU idn number if it already has a value' do
      author = described_class.new(access_id: 'testid')
      author.psu_idn = 'xxxxxxxxx'
      author.update_missing_attributes
      expect(author.psu_idn).to eq('xxxxxxxxx')
    end
  end
  context '#can_edit?' do
    it 'allows the author to edit his or her own record' do
      described_class.current = described_class.new(access_id: 'ME123')
      expect(described_class.new(access_id: 'me123').can_edit?).to be_truthy
    end
    it "does not allow an author to edit someone else's personal information" do
      described_class.current = described_class.new(access_id: 'me123')
      expect { described_class.new(access_id: 'somebodyelse456').can_edit? }.to raise_error(Author::NotAuthorizedToEdit)
    end
  end
  context '#is_admin?' do
    it 'knows when an author has admin privileges' do
      expect(described_class.new(access_id: 'me123', is_admin: true).is_admin?).to be_truthy
      expect(described_class.new(access_id: 'me123', is_admin: nil).is_admin?).to be_falsey
    end
  end
  context '#is_site_admin?' do
    it 'knows when an author has site administration privileges' do
      expect(described_class.new(access_id: 'me123', is_site_admin: true).is_site_admin?).to be_truthy
      expect(described_class.new(access_id: 'me123', is_site_admin: nil).is_site_admin?).to be_falsey
    end
  end
  context '#legacy' do
    it 'identifies legacy records' do
      expect(described_class.new(access_id: 'me123', legacy_id: nil).legacy?).to be_falsey
      expect(described_class.new(access_id: 'me123', legacy_id: '1').legacy?).to be_truthy
    end
  end
end
