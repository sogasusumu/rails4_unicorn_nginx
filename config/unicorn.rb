# -*- coding: utf-8 -*-

rails_root = File.expand_path('../../', __FILE__)
worker_process_counts = 2
sock_name = 'unicorn.sock'
pid_name = 'unicorn.pid'
error_log_name = 'unicorn_error.log'
log_name = 'unicorn.log'

working_directory rails_root
worker_processes worker_process_counts
listen "#{rails_root}/tmp/#{sock_name}"
pid "#{rails_root}/tmp/#{pid_name}"
stderr_path "#{rails_root}/log/#{error_log_name}"
stdout_path "#{rails_root}/log/#{log_name}"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end