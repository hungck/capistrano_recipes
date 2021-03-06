set_default(:puma_role) { :app }
set_default(:puma_config_path) { "#{current_path}/config/puma.rb" }
set_default(:puma_pid_path) { "#{current_path}/tmp/pids/puma.pid" }

namespace :puma do
  desc "Start puma"
  task :start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    puma_env = fetch(:rack_env, fetch(:rails_env, "production"))
    run "cd #{current_path} && #{fetch(:bundle_cmd, 'bundle')} exec puma --daemon --environment #{puma_env} --config #{puma_config_path} --pidfile #{puma_pid_path} >> #{current_path}/log/puma.log 2>&1 &", :pty => false
  end

  desc "Stop puma"
  task :stop, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "kill -s TERM `cat #{puma_pid_path}`"
  end

  desc "Halt puma"
  task :halt, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "kill -s QUIT `cat #{puma_pid_path}`"
  end

  desc "Restart puma"
  task :restart, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    if remote_file_exists? puma_pid_path
      run "kill -s USR2 `cat #{puma_pid_path}`"
    else
      start
    end
  end

  desc "Restart puma in phased mode"
  task :phased_restart, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    if remote_file_exists? puma_pid_path
      run "kill -s USR1 `cat #{puma_pid_path}`"
    else
      start
    end
  end
end
