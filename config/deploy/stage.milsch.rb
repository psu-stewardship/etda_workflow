# frozen_string_literal: true

# config/deploy/stage.milsch.rb

set :default_env, {
    'PARTNER' => 'milsch'
}

set :stage, 'stage'
set :partner, 'milsch'
set :deploy_to, "/opt/deploy/etda_workflow_milsch"
set :tmp_dir, "/opt/deploy/etda_workflow_milsch/tmp"
role :web,  "etdaworkflow1stage.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1stage.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1stage.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1stage.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
