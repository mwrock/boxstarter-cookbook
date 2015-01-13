include_recipe 'boxstarter::default'

boxstarter "Simple Package" do
  disable_reboots true
  password "vagrant"
  code <<-EOH
    cinst console2
  EOH
end