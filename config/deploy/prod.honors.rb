# frozen_string_literal: true

# config/deploy/prod.honors.rb

set :default_env, {
    'PARTNER' => 'honors'
}

set :stage, 'prod'
set :partner, 'honors'
set :deploy_to, "/opt/deploy/etda_workflow_honors"
set :tmp_dir, "/opt/deploy/etda_workflow_honors/tmp"
role :web,  "etdaworkflow1prod.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1prod.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1prod.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1prod.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
