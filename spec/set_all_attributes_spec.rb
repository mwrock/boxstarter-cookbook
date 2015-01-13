require 'spec_helper'
require 'chefspec'
require_relative '../libraries/check_process_tree'
require_relative '../libraries/command'

include Boxstarter::Helper

describe 'boxstarter_spec::set_all_attributes' do
  
  let(:chef_run) do
  	ChefSpec::SoloRunner.new(
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

  it "writes the wrapper file" do
    expect(chef_run).to create_template('/boxstarter/tmp/boxstarter.bat').with(
      source: "ps_wrapper.erb",
      cookbook: "boxstarter",
      variables: {:command => "-EncodedCommand #{command("mypassword", false, false, "/boxstarter/tmp", true)}"})
  end
end