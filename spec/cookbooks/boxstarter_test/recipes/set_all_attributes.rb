include_recipe 'boxstarter::default'

boxstarter "Run Windows Update" do
  password "mypassword"
  disable_reboots true
  start_chef_client_onreboot false
  disable_boxstarter_restart true
  code <<-EOH
    Install-WindowsUpdate -acceptEula
  EOH
end