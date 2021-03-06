# frozen_string_literal: true
set :environment, :production
# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"
set :partner, ENV['PARTNER']

# every :hour, roles: [:db] do
  # rake 'etda:dih:delta_import'
# end

job_type :partner_rake, "cd :path && :environment_variable=:environment PARTNER=:partner bundle exec rake :task --silent :output"

every :day, roles: [:audit] do
  partner_rake 'audit:vulnerabilities'
end

every :sunday, at: '1am', roles: [:app] do
  partner_rake 'final_files:verify'
end

every :day, at: '1am', roles: [:app] do
  partner_rake 'tokens:remove_expired'
end

every :day, at: '1am', roles: [:app] do
  partner_rake 'confidential:update'
end

every '0 1 30 1,5,8 *', roles: [:app] do
  partner_rake 'report:semester_release'
end

every :day, at: '3am', roles: [:app] do
  partner_rake 'lionpath_import:core'
end
