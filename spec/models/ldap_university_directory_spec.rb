# frozen_string_literal: true

# This tests a live LDAP connection
# To run this, comment out line in config/environments/test.rb that sets MockUniversityDirectory
#
require 'model_spec_helper'
require 'support/ldap_lookup'
require 'shared/shared_examples_for_university_directory'

RSpec.describe LdapUniversityDirectory, type: :model, ldap: true do
  subject(:directory) { described_class.new }

  it_behaves_like "a UniversityDirectory"

  describe '#autocomplete' do
    let(:results) { directory.autocomplete(search_string) }

    context "when given the empty string" do
      let(:search_string) { "" }

      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context 'when given "no match"' do
      let(:search_string) { "not there" }

      it "returns an empty array" do
        expect(results).to eq([])
      end
    end

    context "when given a person's complete name" do
      let(:search_string) { "Alex Kiessling" }

      it "returns only the entry for that person" do
        expect(results.count).to eq(1)
        expect(results.first[:label]).to eq("Alex Kiessling")
      end
      it "returns the person's department" do
        expect(results.first[:dept]).to eq("Technology Strategies")
      end
      it "returns the person's email as the id" do
        expect(results.first[:id]).to eq("ajk5603@psu.edu")
      end
    end

    pending('do not have data to test this condition one') do
      context "when the matching person has no email address" do
        let(:search_string) { "Scott Aaron Woods" }

        it "still returns their name" do
          expect(results.first[:label]).to eq("Scott Aaron Woods")
        end
        it "returns a message in the id field" do
          expect(results.first[:id]).to match(/not available/)
        end
      end
    end
    pending('do not have data to test this condition two') do
      context "when the matching person has no deparment" do
        pending("Scott is not available with faculty/staff filter; do not have an example to test this condition")
        let(:search_string) { "Scott Aaron Woods" }

        it "still returns their name" do
          expect(results.first[:label]).to eq("Scott Aaron Woods")
        end
        it "returns a message in the dept field" do
          expect(results.first[:dept]).to match(/not available/)
        end
      end
    end
    context "when given a person's complete name in all lowercase" do
      let(:search_string) { "alex kiessling" }

      it "returns only the entry for that person" do
        expect(results.count).to eq(1)
        expect(results.first[:label]).to eq("Alex Kiessling")
      end
    end

    context "when given a person's complete name without their middle name" do
      let(:search_string) { "Fred Fenstermaker" }

      it "returns only the entry for that person" do
        expect(results.count).to eq(1)
        expect(results.first[:label]).to eq("Fred Frank Fenstermaker")
      end
    end

    context "when given an exact last name" do
      context "that is very short" do
        let(:search_string) { "Li" }
        let(:matching_entry) { results.detect { |r| r[:label] == "Zhao Li" } }

        it "does not return an entry for that person but does return a list of others" do
          expect(matching_entry).not_to be_present
        end
      end
      # context "when given more specific information for the last name that is very short (include first name)" do
      #   let(:search_string) { "Zhao Li" }
      #   let(:matching_entry) { results.detect { |r| r[:label] == "Zhao Li" } }
      #   it "returns an entry for that person" do
      #     expect(matching_entry).to be_present
      #   end
      # end

      context "that has an apostrophe" do
        let(:search_string) { "O'Brien" }
        let(:matching_entry) { results.detect { |r| r[:label] == "Sharon R O'Brien" } }

        it "returns an entry for that person (among others)" do
          expect(matching_entry).to be_present
        end
      end

      context "with trailing whitespace" do
        let(:search_string) { "kiessling " }
        let(:matching_entry) { results.detect { |r| r[:label] == "Alex Kiessling" } }

        it "returns an entry for that person" do
          expect(matching_entry).to be_present
        end
      end

      context "and that person has a middle name" do
        let(:search_string) { "Fenstermaker" }
        let(:matching_entry) { results.detect { |r| r[:label] == "Fred Frank Fenstermaker" } }

        it "returns an entry for Fred Frank Fenstermaker (among others)" do
          expect(matching_entry).to be_present
        end
      end

      context "and that person does not have a middle name" do
        let(:search_string) { "Cory Smith" }
        let(:matching_entry) { results.detect { |r| r[:label] == "Cory Smith" } }

        # This person may disappear from LDAP at some point.
        it "includes the entry for that person" do
          expect(matching_entry).to be_present
        end
      end

      context "and that person has a roman numeral after their last name" do
        let(:search_string) { "vaughn whisker" }
        let(:matching_entry) { results.detect { |r| r[:label] == "Vaughn Eugene Whisker, III" } }

        it "includes entry for the person with roman numerals after last name" do
          expect(matching_entry).to be_present
        end
      end
    end

    context "when given a common string that returns too many results" do
      let(:search_string) { "Smith" }

      it "returns an array with 20 entries" do
        # No sense in filling the autocomplete box with 1000 entries
        expect(results.count).to eq(20)
      end
    end
    # context "when given a non-faculty/staff name" do
    #   let(:search_string) { "Scott Aaron Woods" }
    #   context "and we're limiting to faculty/staff (the default)" do
    #     it "does not return any matches" do
    #       expect(results).to eq([])
    #     end
    #   end
    #   context "and we're including anyone" do
    #     let(:results) { directory.autocomplete(search_string, only_faculty_staff:false) }
    #     let(:matching_entry) { results.detect { |r| r[:label] == "Scott Aaron Woods" } }
    #     it "includes the entry for that person" do
    #       expect(matching_entry).to be_present
    #     end
    #   end
    # end

    context "when given an exact first name" do
      let(:search_string) { "Mairead" }
      let(:matching_entry) { results.detect { |r| r[:label] == "Mairead Martin" } }

      it "does not include an entry for that person" do
        # We don't search for just first names
        expect(matching_entry).not_to be_present
      end
    end

    context "when given a partial first name" do
      let(:search_string) { "Mair" }
      let(:matching_entry) { results.detect { |r| r[:label] == "Mairead Martin" } }

      it "does not include an entry for that person" do
        # We don't search for just first names
        expect(matching_entry).not_to be_present
      end
    end

    context "when given a partial last name" do
      let(:search_string) { "Kies" }
      let(:matching_entry) { results.detect { |r| r[:label] == "Alex Kiessling" } }

      it "includes the entry for that person" do
        expect(matching_entry).to be_present
      end
    end

    context "when given a first name and a partial last name" do
      let(:search_string) { "Alex Kies" }
      let(:matching_entry) { results.detect { |r| r[:label] == "Alex Kiessling" } }

      it "includes the entry for that person" do
        expect(matching_entry).to be_present
      end
    end

    context "when the given string has both exact and partial matches" do
      let(:search_string) { "Mi" }

      it "returns the exact matches first, then the partial matches"
    end

    context "when given a string that includes unicode characters" do
      let(:search_string) { "Muñoz" }

      it "returns an empty array because everything is stored as ASCII" do
        expect(results).to eq([])
      end
    end

    context 'when searching using wildcards' do
      let(:search_string) { "Kies*" }
      let(:matching_entry) { results.detect { |r| r[:label] == "Alex Kiessling" } }

      it "doesn't return any results, since wildcards are not supported for the end user" do
        expect(results).to eq([])
      end
    end

    context "when LDAP is down" do
      let(:search_string) { "joni" }

      before do
        allow(Net::LDAP).to receive(:new).and_raise(Net::LDAP::LdapError)
      end

      it "raises an UnreachableError" do
        expect { results }.to raise_error(LdapUniversityDirectory::UnreachableError)
      end
    end
  end

  describe '#exists?' do
    let(:result) { directory.exists?(access_id) }

    context "when given an unknown access ID" do
      let(:access_id) { "zzz9999" }

      it "returns false" do
        expect(result).to be(false)
      end
    end

    context "when given an access ID that exists" do
      let(:access_id) { "ajk5603" }

      it "returns true" do
        expect(result).to be(true)
      end
    end

    context "when LDAP is down" do
      let(:access_id) { "ajk5603" }

      before do
        allow(Net::LDAP).to receive(:new).and_raise(Net::LDAP::LdapError)
      end

      it "raises an UnreachableError" do
        expect { result }.to raise_error(LdapUniversityDirectory::UnreachableError)
      end
    end
  end

  describe '#retrieve' do
    let(:result) { directory.retrieve(access_id, LdapResultsMap::AUTHOR_LDAP_MAP) }

    context "when given an unknown access ID" do
      let(:access_id) { "zzz9999" }

      it "returns an empty hash" do
        expect(result).to eq({})
      end
    end

    context "when given a valid access ID" do
      let(:access_id) { "ajk5603" }

      it "returns a hash of author attributes" do
        expect(result[:access_id]).to eq('ajk5603') # to confirm that we have the right record
        expect(result[:first_name]).to eq('Alex')
        expect(result[:last_name]).to eq('Kiessling')
        expect(result[:address_1]).to eq('W 313 Pattee Library')
        expect(result[:city]).to eq('University Park')
        expect(result[:state]).to eq('PA')
        expect(result[:zip]).to eq('16802')
        expect(result[:country]).to eq('US')
        expect(result[:phone_number]).to eq('')
        expect(result[:psu_idn][0]).to eq(nil)
      end
    end

    context "when LDAP is down" do
      let(:access_id) { "ajk5603" }

      before do
        allow(Net::LDAP).to receive(:new).and_raise(Net::LDAP::LdapError)
      end

      it "raises an UnreachableError" do
        expect { result }.to raise_error(LdapUniversityDirectory::UnreachableError)
      end
    end
  end

  describe '#get_psu_id' do
    let(:access_id) { 'ajk5603' }

    context "when given an access ID" do
      let(:result) { directory.get_psu_id_number(access_id) }

      it "returns a PSU id" do
        expect(result).to eq(nil)
      end
    end

    context "when given an invalid access ID" do
      let(:result) { directory.get_psu_id_number('bogus') }

      it "returns blank" do
        expect(result).to eq('')
      end
    end
  end
end
