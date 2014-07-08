require 'chefspec'

describe 'boxstarter_test::no_password' do
  
  let(:chef_run) do
  	ChefSpec::Runner.new(
  		cookbook_path: ["#{File.dirname(__FILE__)}/../..","#{File.dirname(__FILE__)}/cookbooks"], 
  		step_into: ['boxstarter']
  		) do | node |
  		node.set['boxstarter']['tmp_dir'] = '/boxstarter/tmp'
  	end.converge(described_recipe)
  end

  it "includes a blank plain password" do
    expect(chef_run).to render_file('/boxstarter/tmp/boxstarter.ps1').with_content(/\$plain_password = ''/)
  end    
end