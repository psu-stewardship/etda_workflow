require 'rails_helper'
require 'shoulda-matchers'
require 'active_record/fixtures'

RSpec.describe "Rake::Task['final_files:verify']", type: :task do

  let(:message) do
    /File Verification for ETDA(.*)\nCreated report(.*)\nPossible match for file(.*)\nCannot verify correct file has been located:(.*)\nFinal Submission Files in database: 3\nMissing and\/or misplaced file count: 1/
  end

  before do
    Rails.application.load_tasks
    root_dir = Rails.root.join('tmp')
    FileUtils.rm_rf(Dir["#{root_dir}/explore/*"])
    FileUtils.rm_rf(Dir["#{root_dir}/workflow/*"])
    submission1 = FactoryBot.create(:submission, :released_for_publication)
    submission2 = FactoryBot.create(:submission, :waiting_for_publication_release)
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'explore', 'explore_file_01.pdf'))
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'workflow', 'workflow_file_01.pdf'))
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'explore', 'explore_file_01.pdf')), submission_id: submission1.id)
    FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'workflow','workflow_file_01.pdf')), submission_id: submission2.id)

  end

  # it 'verifies location of files' do
  #   Rake::Task['final_files:verify'].reenable
  #
  #   # allow_any_instance_of(EtdaFilePaths).to receive(:detailed_file_path).and_return('99/999')
  #   num_files = FinalSubmissionFile.all.count
  #   expect(Rake::Task['final_files:verify'].invoke).to receive(:locate_file).with(000).exactly(1).times.and_return('hello')
  #   puts task_output
  # end

  it 'verifies location of files and identifies misplaced file' do
    submission3 = FactoryBot.create(:submission, :waiting_for_publication_release)
    FileUtils.copy(Rails.root.join('spec', 'fixtures', 'final_submission_file_01.pdf'), Rails.root.join('tmp', 'workflow', 'workflow_file_02.pdf'))
    final_submission = FinalSubmissionFile.create(asset: File.open(Rails.root.join('tmp', 'workflow','workflow_file_02.pdf')), submission_id: submission3.id)
    FileUtils.rm(final_submission.current_location)

    Rake::Task['final_files:verify'].reenable

    expect{ Rake::Task['final_files:verify'].invoke }.to output(message).to_stdout
  end
end