actions :run
default_action :run

attribute :script, 			:kind_of => String, :name_attribute => true,
          :required => true
attribute :code, 			:kind_of => String
attribute :password, 		:kind_of => String
attribute :disable_reboots,	:kind_of => [TrueClass, FalseClass], :default => false
