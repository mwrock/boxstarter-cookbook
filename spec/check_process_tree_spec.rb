require 'spec_helper'
require 'chefspec'
require_relative '../libraries/check_process_tree'

include Boxstarter::Helper

describe 'check_process_tree' do
	before do
		require 'win32ole'
		allow(WIN32OLE).to receive(:connect).with("winmgmts://").and_return(
			Boxstarter::SpecHelper::MockWMI.new([
				Boxstarter::SpecHelper::MockProcess.new('proc1',nil),
				Boxstarter::SpecHelper::MockProcess.new('proc2','cl2'),
				Boxstarter::SpecHelper::MockProcess.new('services.exe','cl3'),
				Boxstarter::SpecHelper::MockProcess.new('proc4','cl4'),
				]))
	end

	context 'when target process is a parent' do
		let(:checker) { check_process_tree(50, :CommandLine, 'cl2') }

		it "will return true" do
			expect(checker).not_to be(nil)
		end
	end

	context 'when parent is nil' do
		let(:checker) { check_process_tree(nil, :CommandLine, 'cl2') }

		it "will return false" do
			expect(checker).to be(nil)
		end
	end

	context 'when target process is not a parent' do
		let(:checker) { check_process_tree(50, :CommandLine, 'targetooney') }

		it "will return false" do
			expect(checker).to be(nil)
		end
	end

	context 'when target process is parent of services.exe' do
		let(:checker) { check_process_tree(50, :CommandLine, 'target') }

		it "will return false because it is skipped" do
			expect(checker).to be(nil)
		end
	end
end