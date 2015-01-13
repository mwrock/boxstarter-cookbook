Boxstarter Cookbook
===================
Run [Boxstarter](http://boxstarter.org) scripts inside Chef!

This cookbook provides a light weight resource allowing you to embed Boxstarter scripts inside your Chef recipes. Boxstarter adds value to your Windows installs by:

- Providing an unattended install experience for installs that may require one or many reboots
- Adds the ability to easily install any [chocolatey](http://chocolatey.org/) package
- Adds several windows specific configuration commands such as tweaking the task bar, customizing explorer options and much more. See [here](http://boxstarter.org/WinConfig) for details
- Supplies an Install-WindowsUpdates command that can install all available critical updates locally or remotely and reboot as many times as necessary

Requirements
------------
Boxstarter can only run on Windows platforms from versions 7/2008R2 and above.

Attributes
----------
````
default['boxstarter']['tmp_dir'] = "#{ENV['TEMP']}/boxstarter"
default['boxstarter']['version'] = "2.4.152"
````
No version is specified by default, installing the latest boxstarter modules.

Usage
-----
#### boxstarter::default

Just include `boxstarter` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[boxstarter]"
  ]
}
```
This will install Chocolatey and the Boxstarter powershell modules required to run boxstartr scripts and load the boxstarter resource.

boxstarter resource
----------
````
include_recipe 'boxstarter::default'

boxstarter "boxstarter run" do
  password default['my_box_cookbook']['my_secret_password']
  disable_reboots false
  code <<-EOH
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
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
````
`password` is the password of the account under which chef-client is running. This is used for two purposes which may not apply to all scenarios:

1. The password is used to log back into the machine after a reboot so that the script can be restarted. If you do not anticipate reboots or have disabled them (see below), then this will not apply.
2. If boxstarter is running remotely from a winrm session (chef-metal, knife bootstrap, test-kitchen or vagrant provisioner), boxstarter may need to create a scheduled task for certain operations in order to run in a local context. This is true for installing windows updates, windows features and MSI installs. Boxstarter will need to create the task with admin credentials and expects the passwoed to belong to the running account.

`disable_reboots` set this to true if you want to ensure that boxstarter will not initiate a reboot.

Running with Chef-client
------------
Normally, boxstarter will automatically logon and restart its script upon reboot. However, if chef-client is installed and the node is regularly converging, boxstarter will not logon and restart. It doesn't need to becuse the chef-client service will automatically start and initiate a convergence which will effectively restart the boxstarter run.

Also note that because the chef-client runs under the local system account by default, the boxstarter logs will not be in their usual location but in `%systemdrive%\ProgramData\Boxstarter`.

Boxstarter Documantation
------------
Visit http://boxstarter.org for complete documentation, as well as links to source code, discussions and bug tracking.

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author: Matt Wrock (matt@mattwrock.com @mwrockx)
Licensed under [Apache 2](https://github.com/mwrock/boxstarter-cookbook/blob/master/LICENSE.txt)
