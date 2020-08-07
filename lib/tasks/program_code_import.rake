namespace :import do

  desc 'Import program codes from lionpath PE_SR_G_ETD_STDNT_PLAN_PRC files'
  task :program_codes, [:file_location] => :environment do |task, args|
    return unless current_partner.graduate?

    `#{Rails.root}/bin/lionpath-program.sh`
    file_location = (args[:file_location].present? ? args[:file_location] : '/var/tmp_lionpath/lionpath.csv')
    csv_options = { headers: true, encoding: "ISO-8859-1:UTF-8", quote_char: '"', force_quotes: true }
    CSV.foreach(file_location, csv_options) do |row|
      program_name = row['Transcript Descr'].to_s.strip
      program = Program.find_by(name: program_name)
      if program.present?
        program.update! code: row['Acadademic Plan'].to_s
      else
        Program.create name: program_name,
            code: row['Acadademic Plan'].to_s,
            is_active: 0
      end
    end
  end
end
