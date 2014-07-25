require 'serverspec'

include Serverspec::Helper::Exec
include SpecInfra::Helper::DetectOS

describe file('C:\\programdata\\chocolatey\\bin\\console.exe') do
  it { should be_file }
end