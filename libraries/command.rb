module BoxstarterLibrary
  module Helper
    def command(password, chef_client_enabled, is_remote, temp_dir, disable_reboots)
      command = <<-EOS
      $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
      $plain_password = '#{password}'
      $disable_reboots = $#{disable_reboots}
      $chef_client_enabled = $#{chef_client_enabled}
      $isRemote = $#{is_remote}

      if($plain_password.length -gt 0) {
        $password = ConvertTo-SecureString $plain_password -asplaintext -force
        $creds = New-Object System.Management.Automation.PSCredential ($identity.Name, $password)
      }

      $params = @{
        PackageName = "#{temp_dir}/package.ps1"
      }

      #if we use the chef_client cookbook and dont want to start 
      #boxstarter on its own after reboot, then do not send 
      #credentials to the boxstarter installer command
      if($creds -and !($chef_client_enabled)){$params['credential'] = $creds}
      if($chef_client_enabled){$params['DisableRestart'] = $true}
      if($disable_reboots){$params['DisableReboots'] = $true}

      #If we are running via winrm perhaps via test-kitchen or chef-metal
      #we will need to create a scheduled task for operations that do
      #not work remotely
      if($isRemote -and $creds){
        Import-Module "$env:appdata/boxstarter/Boxstarter.Common/Boxstarter.Common.psd1"
        Create-BoxstarterTask $creds
      }

      Import-Module "$env:appdata/boxstarter/Boxstarter.Chocolatey/Boxstarter.Chocolatey.psd1"
      $result = Install-BoxstarterPackage @params

      if($result.errors.count -gt 0) {
        Write-Output "ERROR SUMMARY:"
        $i=0
        $result.errors | % {
          $i=$i + 1
          Write-Output "#$($i))"
          $_ | fl * -force
        }
        $host.SetShouldExit($result.errors.count)
      }
      EOS
      Chef::Log.debug "wrapping boxstarter invocation script: #{command}"
      command = command.chars.to_a.join("\x00").chomp
      command << "\x00" unless command[-1].eql? "\x00"
      if(defined?(command.encode))
        command = command.encode('ASCII-8BIT')
        command = Base64.strict_encode64(command)
      else
        command = Base64.encode64(command).chomp
      end
      command
    end
  end
end