use_inline_resources

def whyrun_supported?
  true
end

action :run do
  require 'win32ole'

  return if check_process_tree(Process.ppid, :CommandLine, 'boxstarter')

  code = @new_resource.code || @new_resource.script
  password = @new_resource.password
  disable_reboots = @new_resource.disable_reboots
  disable_boxstarter_restart = @new_resource.disable_boxstarter_restart
  start_chef_client_onreboot = @new_resource.start_chef_client_onreboot
  script_path = "#{node['boxstarter']['tmp_dir']}/package.ps1"

  template script_path do
  	source "package.erb"
    cookbook "boxstarter"
    variables({
      :code => code,
      :start_chef_client_onreboot => start_chef_client_onreboot
    })
  end

  command_path = "#{node['boxstarter']['tmp_dir']}/boxstarter.ps1"
  template command_path do
    source "boxstarter_command.erb"
    cookbook "boxstarter"
    variables({
      :password => password,
      :disable_boxstarter_restart => disable_boxstarter_restart,
      :is_remote => check_process_tree(Process.ppid, :Name, 'winrshost.exe'),
      :temp_dir => node['boxstarter']['tmp_dir'],
      :disable_reboots => disable_reboots
    })
  end

  batch_path = "#{node['boxstarter']['tmp_dir']}/boxstarter.bat"
  template batch_path do
    source "ps_wrapper.erb"
    cookbook "boxstarter"
    variables({
      :command => "-file #{command_path}"
    })
  end

  execute batch_path do
    timeout 7200
  end

  # cmd = Mixlib::ShellOut.new(batch_path)
  # Chef::Log.debug(cmd)
  # cmd.live_stream = cmd.stdout
  # cmd.timeout = 7200
  # cmd.run_command
end
