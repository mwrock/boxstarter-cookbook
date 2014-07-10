require 'win32ole'

use_inline_resources

def whyrun_supported?
  true
end

action :run do
  return if child_of_boxstarter(Process.ppid)

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

def child_of_boxstarter(parent)
  Chef::Log.info "***Looking for boxstarter parents at pid #{parent}***"

  if parent.nil?
    Chef::Log.info "***No more parents. Finished looking for boxstarter parents***"
    return false 
  end

  wmi = WIN32OLE.connect("winmgmts://")
  parent_proc = wmi.ExecQuery("Select * from Win32_Process where ProcessID=#{parent}")
  
  if parent_proc.each.count == 0
    Chef::Log.info "***No process for pid #{parent}. Finished looking for boxstarter parents***"
    return false
  end

  proc = parent_proc.each.next

  if !proc.CommandLine.nil? && proc.CommandLine.downcase.include?('boxstarter')
    Chef::Log.info "***Found boxstarter parent pid #{parent}...returning true***"
    return true 
  end

  Chef::Log.info "***Proc was running #{proc.Name}...trying its parent***"
  return child_of_boxstarter(proc.ParentProcessID)
end