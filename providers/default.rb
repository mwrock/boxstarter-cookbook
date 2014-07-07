use_inline_resources

def whyrun_supported?
  true
end

action :run do
  code = @new_resource.code || @new_resource.script
  script_path = "#{node['boxstarter']['tmp_dir']}/scriptblock.ps1"
  template script_path do
  	source "package.erb"
    variables({
      :code => code
    })
  end

  command_path = "#{node['boxstarter']['tmp_dir']}/scriptblockboxstarter.bat"
  template command_path do
    source "ps_wrapper.erb"
    variables({
      :command => "-file '#{script_path}'"
    })
  end

  execute command_path
end
