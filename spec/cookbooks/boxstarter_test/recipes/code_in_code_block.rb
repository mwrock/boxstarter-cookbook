boxstarter "Run Windows Update" do
  password "mypassword"
  code <<-EOH
    Install-WindowsUpdate -acceptEula
  EOH
end