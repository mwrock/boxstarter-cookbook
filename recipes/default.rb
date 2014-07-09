return 'platform not supported' if node['platform_family'] != 'windows'

directory default['boxstarter']['tmp_dir']

cookbook_file "bootstrapper.ps1" do
  path "#{ENV['TEMP']}/boxstarter/bootstrapper.ps1"
  action :create
end

template "#{ENV['TEMP']}/boxstarter/setup.bat" do
  source "ps_wrapper.erb"
  variables({
    :command => "-command \". '%~dp0bootstrapper.ps1';Get-Boxstarter -force\""
  })
end

execute 'install boxstarter' do
  command "#{ENV['TEMP']}/boxstarter/setup.bat"
  not_if { ::Dir.exist?(::File.join(ENV['AppData'], 'boxstarter')) }
end
