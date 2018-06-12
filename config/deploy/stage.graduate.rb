# frozen_string_literal: true

# config/deploy/stage.graduate.rb
set :stage, 'stage'
set :partner, 'graduate'
set :deploy_to, "/opt/deploy/etda_workflow_graduate"
set :tmp_dir, "/opt/deploy/etda_workflow_graduate/tmp"
role :web, %w[deploy@etdaworkflow1stage.vmhost.psu.edu:1855]
role :app,  "etdaworkflow1stage.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1stage.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
role :audit, "etdaworkflow1stage.vmhost.psu.edu:1855" # this is where bundle:audit runs
server 'etdaworkflow1stage.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
