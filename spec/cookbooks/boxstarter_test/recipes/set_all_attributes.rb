include_recipe 'boxstarter::default'

boxstarter "Run Windows Update" do
  password "mypassword"
  disable_reboots true
  code <<-EOH
    Install-WindowsUpdate -acceptEula
  EOH
end