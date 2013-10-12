set :rails_env, 'production'

role :web, 'explorer@sca1.flame.org'
role :app, 'explorer@sca1.flame.org'
role :db,  'explorer@sca1.flame.org', :primary => true
#role :db,  "your slave db-server here"

set :server_hostname, 'thing.pennsicuniversity.org'
set :server_socket, 'thing' # historical
