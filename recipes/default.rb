Chef::Provider::Boxstarter.send(:include, BoxstarterLibrary::Helper)

version = nil
if node['boxstarter']['version']
  version = "-version '#{node['boxstarter']['version']}' "
end

directory node['boxstarter']['tmp_dir']

cookbook_file "bootstrapper.ps1" do
  path "#{node['boxstarter']['tmp_dir']}/bootstrapper.ps1"
  action :create
end

template "#{node['boxstarter']['tmp_dir']}/setup.bat" do
  source "ps_wrapper.erb"
  variables({
    :command => "-command \". '%~dp0bootstrapper.ps1';Get-Boxstarter #{version}-force\""
  })
end

execute 'install boxstarter' do
  command "#{node['boxstarter']['tmp_dir']}/setup.bat"
end
