set :rails_env, 'production'

role :web, 'explorer@sca-do1.flame.org'
role :app, 'explorer@sca-do1.flame.org'
role :db,  'explorer@sca-do1.flame.org', :primary => true
#role :db,  "your slave db-server here"

set :server_hostname, 'sca-do1.flame.org'
set :server_socket, 'thing' # historical
