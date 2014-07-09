use_inline_resources

def whyrun_supported?
  true
end

action :run do
  code = @new_resource.code || @new_resource.script
  password = @new_resource.password
  script_path = "#{node['boxstarter']['tmp_dir']}/package.ps1"

  directory node['boxstarter']['tmp_dir']

  template script_path do
  	source "package.erb"
    cookbook "boxstarter"
    variables({
      :code => code
    })
  end

  command_path = "#{node['boxstarter']['tmp_dir']}/boxstarter.ps1"
  template command_path do
    source "boxstarter_command.erb"
    cookbook "boxstarter"
    variables({
      :password => password,
      :temp_dir => node['boxstarter']['tmp_dir']
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

  execute batch_path
end
