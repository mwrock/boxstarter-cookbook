require 'chefspec'

describe 'boxstarter_test::code_in_code_block' do
  
  let(:chef_run) do
  	ChefSpec::Runner.new(
  		cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"], 
  		step_into: ['boxstarter']
  		) do | node |
  		node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
  	end.converge(described_recipe)
  end

  it "writes code to package file" do
    expect(chef_run).to render_file('/boxstarter/tmp/package.ps1').with_content(/Install-WindowsUpdate -acceptEula/)
  end
  it "writes the install command to the command file" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.ps1').with_content(/"\/boxstarter\/tmp\/package.ps1"/)
  end  
  it "includes password in the command file" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.ps1').with_content(/\$plain_password = 'mypassword'/)
  end    
  it "writes the wrapper file" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.bat').with_content(/-file '\/boxstarter\/tmp\/boxstarter.ps1'/)
  end
  it "executes the wrapper" do
    expect(chef_run).to run_execute('/boxstarter/tmp/boxstarter.bat')
  end

end