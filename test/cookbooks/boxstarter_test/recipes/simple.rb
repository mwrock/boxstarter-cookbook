include_recipe 'boxstarter::default'

boxstarter "Simple Package" do
  disable_reboots true
  code <<-EOH
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
    cinst console2
  EOH
end