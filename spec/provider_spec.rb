require 'chefspec'

describe 'boxstarter provider' do
  
  let(:chef_run) do
  	ChefSpec::Runner.new(
  		cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"], 
  		step_into: ['boxstarter']
  		) do | node |
  		node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
  	end.converge('boxstarter_test::default')
  end
  before do
    allow(Boxstarter::Helper).to receive(:check_process_tree).with(anything).and_return(true)
  end

  it "creates temp directory" do
    expect(chef_run).to create_directory('/boxstarter/tmp')
  end
  it "writes code to package file" do
    expect(chef_run).to render_file('/boxstarter/tmp/package.ps1').with_content(/Install-WindowsUpdate -acceptEula/)
  end
  it "writes the install command to the command file" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.ps1').with_content(/"\/boxstarter\/tmp\/package.ps1"/)
  end  
  it "writes the wrapper file" do
    expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.bat').with(
      source: "ps_wrapper.erb",
      cookbook: "boxstarter",
      variables: {:command => "-file /boxstarter/tmp/boxstarter.ps1"})
  end
  it "executes the wrapper" do
    expect(chef_run).to run_execute('/boxstarter/tmp/boxstarter.bat')
  end
  it "includes a blank plain password" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.ps1').with_content(/\$plain_password = ''/)
  end    
end