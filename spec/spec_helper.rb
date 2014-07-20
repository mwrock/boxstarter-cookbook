module Boxstarter
	module SpecHelper

		class MockWMI
			def initialize(procs)
				@procs = procs
			end

			def ExecQuery(query)
				proc = @procs.shift
				proc.nil? ? [] : [proc]
			end
		end

		class MockProcess
			def initialize(name, command_line)
				@Name = name
				@CommandLine = command_line
			end

			def ParentProcessID
			    return 0
			end

			attr_reader :Name
			attr_reader :CommandLine
		end
	end
end