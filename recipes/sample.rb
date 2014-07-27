include_recipe 'boxstarter::default'

boxstarter "boxstarter run" do
  password 'Pass@word1'
  code <<-EOH
    Enable-RemoteDesktop
    cinst console2
    cinst fiddler4
    cinst git-credential-winstore
    cinst poshgit
    cinst dotpeek

    cinst IIS-WebServerRole -source windowsfeatures    
    Install-WindowsUpdate -acceptEula
  EOH
end