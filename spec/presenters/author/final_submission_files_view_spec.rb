require 'presenters/presenters_spec_helper'
RSpec.describe Author::FinalSubmissionFilesView do
  let(:view) { described_class.new(submission) }

  describe "Access Level View", honors: true, milsch: true do
    let(:submission) { FactoryBot.create :submission }

    context 'different access_level partial is returned depending upon current partner' do
      it 'returns access_level_static partial for Millennium Scholars' do
        expect(view.author_access_level_view).to eql('access_level_static') if current_partner.milsch?
      end
      it 'returns access_level_static partial for Honors' do
        expect(view.author_access_level_view).to eql('access_level_standard') if current_partner.honors?
      end
      it 'returns access_level_standard partial for Grad School' do
        expect(view.author_access_level_view).to eq('access_level_standard') if current_partner.graduate?
      end
    end
  end

  describe 'disclosure_class', milsch: true do
    let(:submission) { FactoryBot.create :submission }

    context 'when graduate or honors student chooses open access or restricted_to_institution' do
      it 'returns hidden class' do
        unless current_partner.milsch?
          submission.access_level = 'open_access'
          expect(view.disclosure_class).to eq('d-none')
          submission.access_level = 'restricted_to_institution'
          expect(view.disclosure_class).to eq('d-none')
        end
      end
    end

    context 'milsch with all access levels' do
      it 'returns empty class' do
        if current_partner.milsch?
          submission.access_level = 'restricted'
          expect(view.disclosure_class).to eq('')
          submission.access_level = 'restricted_to_institution'
          expect(view.disclosure_class).to eq('')
          submission.access_level = 'open_access'
          expect(view.disclosure_class).to eq('')
        end
      end
    end

    context 'when restricted is selected by Graduate author' do
      it 'returns an empty class', honors: true do
        submission.access_level = 'restricted'
        expect(view.disclosure_class).to eq('') if current_partner.graduate?
      end
    end
  end

  describe 'selected_access_level' do
    let(:submission) { FactoryBot.create :submission }

    context 'access_level is empty' do
      it 'returns open_access label' do
        submission.access_level = ""
        expect(view.selected_access_level).to eq('Open Access')
        submission.access_level = 'open_access'
        expect(view.selected_access_level).to eq(submission.current_access_level.label)
      end
    end

    context 'restricted_to_institution' do
      it 'returns restricted_to_institution label' do
        submission.access_level = 'restricted_to_institution'
        expect(view.selected_access_level).to eq(submission.current_access_level.label)
      end
    end

    context 'restricted' do
      it 'returns restricted label' do
        submission.access_level = 'restricted'
        expect(view.selected_access_level).to eq(submission.current_access_level.label)
      end
    end
  end
end
