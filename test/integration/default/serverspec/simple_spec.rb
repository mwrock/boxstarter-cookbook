require 'serverspec'

include Serverspec::Helper::Exec
include SpecInfra::Helper::DetectOS

describe file('C:\\programdata\\chocolatey\\bin\\console.exe') do
  it { should be_file }
end
describe file('C:\\users\\administrator\\appdata\\local\\temp\\boxstarter\\boxstarter.ps1') do
  it { should_not be_file }
end
describe file('C:\\users\\administrator\\appdata\\local\\temp\\boxstarter\\boxstarter.bat') do
  it { should_not be_file }
end