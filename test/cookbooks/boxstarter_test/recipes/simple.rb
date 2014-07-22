include_recipe 'boxstarter::default'

boxstarter "Simple Package" do
  disable_reboots true
  code <<-EOH
    Set-WindowsExplorerOptions -EnableShowHidenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
    cinst console2
  EOH
end