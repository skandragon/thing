role :web, 'explorer@moghedien.flame.org'
role :app, 'explorer@moghedien.flame.org'
role :db,  'explorer@moghedien.flame.org', :primary => true
#role :db,  "your slave db-server here"

set :server_hostname, 'gulfwars.flame.org'
set :server_socket, 'gulfwars'
