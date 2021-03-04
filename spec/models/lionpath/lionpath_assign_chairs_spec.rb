require 'model_spec_helper'

RSpec.describe Lionpath::LionpathAssignChairs do
  subject(:lionpath_assign_chairs) { described_class.new }

  describe '#call' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
    let!(:program_head_role) { CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: degree.degree_type) }
    let!(:program) { FactoryBot.create :program }
    let!(:program_chair) { FactoryBot.create :program_chair, program: program, campus: 'UP', access_id: 'abc123' }

    context 'when submission was created before 1 month ago' do
      let!(:submission) do
        FactoryBot.create :submission, created_at: (DateTime.now - 2.months), degree: degree, program: program,
                                       campus: 'UP', lionpath_updated_at: DateTime.now
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it 'does not get a chair' do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
      end

      it 'does not update chair' do
        committee_member.update committee_role: program_head_role
        expect { lionpath_assign_chairs.call }.not_to(change { CommitteeMember.find(committee_member.id) })
      end
    end

    context 'when submission does not have a lionpath_updated_at timestamp' do
      let!(:submission) do
        FactoryBot.create :submission, year: (DateTime.now.year + 1.year), semester: 'Spring',
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it 'does not get a chair' do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
      end
    end

    context 'when submission already has a program chair' do
      let!(:submission) do
        FactoryBot.create :submission, year: DateTime.now.year, semester: 'Summer', lionpath_updated_at: DateTime.now,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:program_head_member) do
        FactoryBot.create :committee_member, committee_role: program_head_role, submission: submission
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it "updates pre-existing program chair in submissions' committee" do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 0
        expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
      end
    end

    context "when submission doesn't have a program chair yet" do
      let!(:submission) do
        FactoryBot.create :submission, year: DateTime.now.year, semester: 'Summer', lionpath_updated_at: DateTime.now,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it "adds program chair to submissions' committee" do
        expect { lionpath_assign_chairs.call }.to change(CommitteeMember, :count).by 1
        expect(Submission.find(submission.id).committee_members.second.access_id).to eq program_chair.access_id
        expect(Submission.find(submission.id).committee_members.second.is_voting).to eq false
        expect(Submission.find(submission.id).committee_members.second.is_required).to eq true
      end
    end
  end
end
