require 'spec_helper'
require 'chefspec'
require_relative '../libraries/check_process_tree'
require_relative '../libraries/command'

include Boxstarter::Helper

describe 'boxstarter provider' do
  
  let(:chef_run) do
  	ChefSpec::SoloRunner.new(
  		cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"], 
  		step_into: ['boxstarter']
  		) do | node |
      node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
      node.automatic['platform_family'] = 'windows'
  	end.converge('boxstarter_spec::default')
  end
  before do
    require 'win32ole'
    allow(WIN32OLE).to receive(:connect).with("winmgmts://").and_return(
      Boxstarter::SpecHelper::MockWMI.new([]))
  end

  it "creates temp directory" do
    expect(chef_run).to create_directory('/boxstarter/tmp')
  end
  it "copies boxstarter installer" do
    expect(chef_run).to create_cookbook_file('/boxstarter/tmp/bootstrapper.ps1')
  end
  it "writes installer wrapper" do
    expect(chef_run).to create_template('/boxstarter/tmp/setup.bat').with(
      source: "ps_wrapper.erb",
      variables: {
        :command => "-command \". '%~dp0bootstrapper.ps1';Get-Boxstarter -force\""})
  end
  it "executes the installer" do
    expect(chef_run).to run_execute('/boxstarter/tmp/setup.bat')
  end
  it "writes code to package file" do
    expect(chef_run).to create_template('/boxstarter/tmp/package.ps1').with(
      source: "package.erb",
      cookbook: "boxstarter",
      variables: {
        :code => "Install-WindowsUpdate -acceptEula",
        :chef_client_enabled => false,
        :chef_client_command => "#{$0}.bat #{ARGV.join(' ')}"})
  end
  it "writes the wrapper file" do
    expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.bat').with(
      source: "ps_wrapper.erb",
      cookbook: "boxstarter",
      variables: {:command => "-EncodedCommand #{command(nil, false, false, "/boxstarter/tmp", false)}"})
  end
  it "executes the wrapper" do
    expect(chef_run).to run_ruby_block('Run Boxstarter Package')
  end
  it "cleans up batch file" do
    expect(chef_run).to delete_file('/boxstarter/tmp/boxstarter.bat')
  end

  context 'when specifying a version' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"]) do | node |
        node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
        node.set['boxstarter']['version'] = '9.9.9'
        node.automatic['platform_family'] = 'windows'
      end.converge('boxstarter_test::default')
    end

    it "writes installer wrapper with the version in the node" do
      expect(chef_run).to create_template('/boxstarter/tmp/setup.bat').with(
        source: "ps_wrapper.erb",
        variables: {
          :command => "-command \". '%~dp0bootstrapper.ps1';Get-Boxstarter -version '9.9.9' -force\""})
    end
  end

  context 'when running on non windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"]) do | node |
        node.automatic['platform_family'] = 'not_windows'
      end.converge('boxstarter_test::default')
    end

    it 'raises an error' do
      expect {chef_run}.to raise_error
    end
  end

  context 'when spawned from another boxstarter run' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"]) do | node |
        node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
        node.automatic['platform_family'] = 'windows'
      end.converge('boxstarter_test::default')
    end
    before do
      require 'win32ole'
      allow(WIN32OLE).to receive(:connect).with("winmgmts://").and_return(
        Boxstarter::SpecHelper::MockWMI.new(['proc','boxstarter']))
    end

    it "does not execute the wrapper" do
      expect(chef_run).not_to run_execute('/boxstarter/tmp/boxstarter.bat')
    end
  end

  context 'when running remotely' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"],
        step_into: ['boxstarter']
        ) do | node |
        node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
        node.automatic['platform_family'] = 'windows'
      end.converge('boxstarter_test::default')
    end
    before do
      require 'win32ole'
      allow(WIN32OLE).to receive(:connect).with("winmgmts://").and_return(
        Boxstarter::SpecHelper::MockWMI.new([Boxstarter::SpecHelper::MockProcess.new('winrshost1.exe',nil)]),
        Boxstarter::SpecHelper::MockWMI.new([Boxstarter::SpecHelper::MockProcess.new('winrshost.exe',nil)]))
    end
    it "writes the wrapper file" do
      expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.bat').with(
        source: "ps_wrapper.erb",
        cookbook: "boxstarter",
        variables: {:command => "-EncodedCommand #{command(nil, false, true, "/boxstarter/tmp", false)}"})
    end
  end

  context 'when the chef_client cookbook is used' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"],
        step_into: ['boxstarter']
        ) do | node |
        node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
        node.set['chef_client']['init_style'] = 'service'
        node.automatic['platform_family'] = 'windows'
      end.converge('boxstarter_test::default')
    end

    it "writes the wrapper file" do
      expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.bat').with(
        source: "ps_wrapper.erb",
        cookbook: "boxstarter",
        variables: {:command => "-EncodedCommand #{command(nil, true, false, "/boxstarter/tmp", false)}"})
    end
    it "informs package template chef client is used" do
      expect(chef_run).to create_template('/boxstarter/tmp/package.ps1').with(
        source: "package.erb",
        cookbook: "boxstarter",
        variables: {
          :code => "Install-WindowsUpdate -acceptEula",
        :chef_client_enabled => true,
        :chef_client_command => "#{$0}.bat #{ARGV.join(' ')}"})
    end
  end  
end