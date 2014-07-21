require 'spec_helper'
require 'chefspec'
require_relative '../libraries/check_process_tree'

describe 'boxstarter_test::set_all_attributes' do
  
  let(:chef_run) do
  	ChefSpec::Runner.new(
  		cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"], 
  		step_into: ['boxstarter']
  		) do | node |
  		node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
      node.automatic['platform_family'] = 'windows'
  	end.converge(described_recipe)
  end
  before do
    require 'win32ole'
    allow(WIN32OLE).to receive(:connect).with("winmgmts://").and_return(
      Boxstarter::SpecHelper::MockWMI.new([]))
  end

  it "writes code to package file" do
    expect(chef_run).to create_template('/boxstarter/tmp/package.ps1').with(
      source: "package.erb",
      cookbook: "boxstarter",
      variables: {
        :code => "    Install-WindowsUpdate -acceptEula\n",
        :start_chef_client_onreboot => true})
  end
  it "writes command file with the correct parameters" do
    expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.ps1').with(
      source: "boxstarter_command.erb",
      cookbook: "boxstarter",
      variables: {
        :password => "mypassword",
        :disable_boxstarter_restart => false,
        :is_remote => false,
        :temp_dir => "/boxstarter/tmp",
        :disable_reboots => true})
  end    
end